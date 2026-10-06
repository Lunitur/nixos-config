const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const vm = require("node:vm");

const source = fs.readFileSync(path.join(__dirname,
  "../modules/features/services/matrix-registration/register.js"), "utf8");

function page(replies, { native = true, confirmPassword = "test password" } = {}) {
  const requests = [];
  const messages = [];
  let submit;
  const button = { disabled: false };
  const fields = {
    username: { value: "Alice" },
    password: { value: "test password" },
    "confirm-password": { value: confirmPassword },
    "registration-token": { value: " invitation " },
    status: { textContent: "" },
    registration: {
      querySelector: () => button,
      addEventListener: (_, handler) => { submit = handler; },
      reset: () => { fields.password.value = ""; fields["registration-token"].value = ""; },
      hidden: false,
    },
  };
  const context = vm.createContext({
    URLSearchParams,
    window: {
      location: { origin: "https://matrix.example.org", search: "?device_id=MOBILE" },
      ...(native ? { sendObjectMessage: (message) => messages.push(message) } : {}),
    },
    document: { getElementById: (id) => fields[id] },
    fetch: async (url, options) => {
      requests.push({ url, ...options, body: JSON.parse(options.body) });
      const reply = replies.shift();
      assert.ok(reply, "Unexpected additional request");
      if (reply instanceof Error) throw reply;
      return { status: reply.status, ok: reply.status === 200, json: async () => reply.data };
    },
  });
  vm.runInContext(source, context);
  return { requests, messages, fields, button, submit: () => submit({ preventDefault() {} }) };
}

const tokenChallenge = () => ({ status: 401, data: {
  flows: [{ stages: ["m.login.registration_token"] }], session: "session",
} });
const success = () => ({ status: 200, data: {
  user_id: "@alice:example.org", device_id: "MOBILE", access_token: "test-access-token",
} });

test("token registration hands complete credentials to Android and legacy fields to iOS", async () => {
  const p = page([tokenChallenge(), success()]);
  await p.submit();
  assert.equal(p.requests.length, 2);
  assert.equal(p.requests[0].url, "/_matrix/client/v3/register");
  assert.equal(p.requests[0].body.username, "alice");
  assert.equal(p.requests[0].body.device_id, "MOBILE");
  assert.equal(p.requests[0].body.inhibit_login, false);
  assert.deepEqual(p.requests[1].body.auth,
    { type: "m.login.registration_token", session: "session", token: "invitation" });
  const message = p.messages[0];
  assert.equal(message.action, "onRegistered");
  assert.equal(message.credentials.device_id, "MOBILE");
  assert.equal(message.credentials.home_server, "example.org");
  assert.equal(message.credentials.well_known["m.homeserver"].base_url, "https://matrix.example.org");
  assert.equal(message.homeServer, "https://matrix.example.org");
  assert.equal(message.userId, "@alice:example.org");
  assert.equal(message.accessToken, "test-access-token");
  assert.equal(p.fields.registration.hidden, true);
  assert.equal(p.fields.password.value, "");
  assert.equal(p.fields["registration-token"].value, "");
});

test("browser signup avoids creating an unused login session", async () => {
  const p = page([tokenChallenge(), { status: 200, data: { user_id: "@alice:example.org" } }], { native: false });
  await p.submit();
  assert.equal(p.requests[0].body.inhibit_login, true);
  assert.equal(p.messages.length, 0);
  assert.match(p.fields.status.textContent, /Return to Element to sign in/);
});

test("invalid invitation leaves the form available and reports the server error as text", async () => {
  const p = page([tokenChallenge(), { status: 403, data: { error: "<invalid invitation>" } }]);
  await p.submit();
  assert.equal(p.messages.length, 0);
  assert.equal(p.fields.status.textContent, "<invalid invitation>");
  assert.equal(p.fields.registration.hidden, false);
  assert.equal(p.button.disabled, false);
});

test("mismatched passwords do not make a registration request", async () => {
  const p = page([], { confirmPassword: "different" });
  await p.submit();
  assert.equal(p.requests.length, 0);
  assert.match(p.fields.status.textContent, /passwords do not match/);
});

test("unsupported registration policy is not bypassed", async () => {
  const p = page([{ status: 401, data: {
    flows: [{ stages: ["m.login.email.identity"] }], session: "session",
  } }]);
  await p.submit();
  assert.equal(p.requests.length, 1);
  assert.equal(p.messages.length, 0);
  assert.match(p.fields.status.textContent, /cannot complete/);
});

test("completed token stage is preserved when a dummy stage remains", async () => {
  const stages = ["m.login.registration_token", "m.login.dummy"];
  const p = page([
    { status: 401, data: { flows: [{ stages }], session: "session" } },
    { status: 401, data: { flows: [{ stages }], session: "session", completed: [stages[0]] } },
    success(),
  ]);
  await p.submit();
  assert.deepEqual(p.requests[2].body.auth, { type: "m.login.dummy", session: "session" });
  assert.equal(p.messages.length, 1);
});

test("network failure restores the submit button", async () => {
  const p = page([new Error("Failed to fetch")]);
  await p.submit();
  assert.equal(p.messages.length, 0);
  assert.equal(p.button.disabled, false);
  assert.equal(p.fields.registration.hidden, false);
});
