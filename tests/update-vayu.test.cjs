const assert = require("node:assert/strict");
const { spawnSync } = require("node:child_process");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const { test, after } = require("node:test");

const script = path.resolve(__dirname, "../scripts/update-vayu.sh");
const fixture = fs.mkdtempSync(path.join(os.tmpdir(), "update-vayu-test-"));
after(() => fs.rmSync(fixture, { recursive: true, force: true }));
fs.mkdirSync(path.join(fixture, "system/bin"), { recursive: true });
fs.writeFileSync(path.join(fixture, "system/bin/switch-to-configuration"), "#!/bin/sh\nexit 0\n", { mode: 0o755 });
fs.writeFileSync(path.join(fixture, "system/boot.json"), JSON.stringify({
  "org.nixos.bootspec.v1": {
    kernel: "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-kernel/Image",
    initrd: "/nix/store/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb-initrd/initrd",
  },
  "org.nixos.systemd-boot": {
    devicetree: "/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-kernel/dtbs/vayu.dtb",
  },
}));
const added = spawnSync("nix-store", ["--add", path.join(fixture, "system")], { encoding: "utf8" });
assert.equal(added.status, 0, added.stderr);
const system = added.stdout.trim();

const bin = path.join(fixture, "bin");
fs.mkdirSync(bin);
const mock = `#!${process.execPath}
const fs = require("node:fs");
const path = require("node:path");
const tool = path.basename(process.argv[1]);
const args = process.argv.slice(2);
const command = args.at(-1) || "";
const input = tool === "ssh" && command.includes("bash -s") ? fs.readFileSync(0, "utf8") : "";
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify({ tool, args, input }) + "\\n");
if (tool === "nix" && args[0] === "build") console.log(process.env.TEST_SYSTEM);
if (tool === "ssh") {
  if (args[0] === "-G") console.log("user carjin");
  else if (command.includes("/etc/machine-id")) console.log("phone-id");
  else if (command.includes("addr show")) console.log("2: wlan0 inet 192.168.1.42/24 scope global wlan0");
  else if (command.includes("id -u")) console.log(process.env.TEST_UID || "0");
  else if (command.includes("bash -s")) process.exit(Number(
    command.includes("-- verify ") ? process.env.TEST_VERIFY_EXIT || 0 : process.env.TEST_BOOT_EXIT || 0
  ));
  else if (command.includes("systemd-run")) process.exit(Number(process.env.TEST_START_EXIT || 0));
  else if (command.includes("is-active")) {
    console.log(process.env.TEST_STATE || "active");
    process.exit(process.env.TEST_STATE === "failed" ? 3 : 0);
  }
}
`;
for (const tool of ["ssh", "nix", "nix-store"]) {
  fs.writeFileSync(path.join(bin, tool), mock, { mode: 0o755 });
}

function run(args, env = {}) {
  const log = path.join(fixture, `log-${Math.random()}`);
  const result = spawnSync("bash", [script, ...args], {
    encoding: "utf8",
    timeout: 10000,
    env: {
      ...process.env,
      PATH: `${bin}:${process.env.PATH}`,
      SSH_HOST: "root@phone",
      FLAKE: "~/nixos",
      TEST_LOG: log,
      TEST_SYSTEM: system,
      ...env,
    },
  });
  assert.ifError(result.error);
  const calls = fs.existsSync(log) ? fs.readFileSync(log, "utf8").trim().split("\n").map(JSON.parse) : [];
  return { ...result, calls };
}

test("help and invalid options do not contact the phone", () => {
  for (const [args, status] of [
    [["--help"], 0],
    [["--host"], 1],
    [["--unknown"], 1],
    [["--reboot", "--no-bootloader"], 1],
  ]) {
    const result = run(args);
    assert.equal(result.status, status, result.stderr);
    assert.equal(result.calls.length, 0);
  }
});

test("builds from the flake and checks boot files before activation and reboot", () => {
  const result = run(["--no-local", "--reboot"]);
  assert.equal(result.status, 0, result.stderr);
  const build = result.calls.find(c => c.tool === "nix" && c.args[0] === "build");
  assert.equal(build.args[1], `${os.homedir()}/nixos#nixosConfigurations.vayu.config.system.build.toplevel`);
  const index = pattern => result.calls.findIndex(c => c.args.at(-1).includes(pattern));
  assert.ok(index("bash -s") < index("systemd-run"));
  assert.ok(index("systemctl is-active") < index("systemctl reboot"));
  const boot = result.calls.find(c => c.input);
  assert.match(boot.args.at(-1), /vayu\.dtb/);
  assert.match(boot.input, /nix-store --verify-path/);
  assert.match(boot.input, /cmp -s/);
});

test("boot verification failure prevents activation and reboot", () => {
  const result = run(["--system", system, "--no-local", "--reboot"], { TEST_BOOT_EXIT: "1" });
  assert.notEqual(result.status, 0);
  assert.ok(!result.calls.some(c => /systemd-run|systemctl reboot/.test(c.args.at(-1))));
});

test("temporary activation does not touch the system profile or bootloader", () => {
  const result = run(["--system", system, "--no-local", "--no-bootloader"]);
  assert.equal(result.status, 0, result.stderr);
  assert.ok(!result.calls.some(c => c.input));
  const activation = result.calls.find(c => c.args.at(-1).includes("systemd-run"));
  assert.match(activation.args.at(-1), /switch-to-configuration test\s*$/);
});

test("an SSH disconnect is accepted only after systemd confirms activation", () => {
  const result = run(["--system", system, "--no-local"], { TEST_START_EXIT: "255" });
  assert.equal(result.status, 0, result.stderr);
  assert.ok(result.calls.some(c => c.args.at(-1).includes("systemctl is-active")));
});

test("failed activation prevents reboot", () => {
  const result = run(["--system", system, "--no-local", "--reboot"], { TEST_STATE: "failed" });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Activation failed/);
  assert.ok(!result.calls.some(c => c.args.at(-1).includes("systemctl reboot")));
});

test("ESP verification after activation must succeed before reboot", () => {
  const result = run(["--system", system, "--no-local", "--reboot"], { TEST_VERIFY_EXIT: "1" });
  assert.notEqual(result.status, 0);
  assert.ok(result.calls.some(c => c.args.at(-1).includes("systemd-run")));
  assert.ok(!result.calls.some(c => c.args.at(-1).includes("systemctl reboot")));
});

test("LAN discovery preserves the SSH user and non-root privilege escalation", () => {
  const result = run(["--system", system, "--host", "carjin@phone"], { TEST_UID: "1000" });
  assert.equal(result.status, 0, result.stderr);
  const copy = result.calls.find(c => c.tool === "nix" && c.args[0] === "copy");
  assert.ok(copy.args.includes("ssh://carjin@192.168.1.42"));
  const boot = result.calls.find(c => c.input);
  assert.match(boot.args.at(-1), /^sudo -n bash -s/);
});
