# Atuin sync

Nano hosts the sync server at `https://anarhizam.org/atuin`, backed by its
local PostgreSQL database. All hosts run the Atuin daemon and sync every minute
after logging in. Credentials and encryption keys stay outside the Nix store.

## Deploy

Apply this configuration on Nano first, then on each client:

```sh
sudo nixos-rebuild switch --flake path:.#nano
```

On each other host, run the same command from its checkout with its own flake
name: `victus`, `corebook`, `minibook`, or `vayu`.

## Connect the hosts

Public registration is blocked by nginx. Create the shared account once on Nano
through the loopback listener:

```sh
ssh nano
ATUIN_SYNC_ADDRESS=http://127.0.0.1:8888/atuin atuin register -u carjin -e karlo.puselj@gmail.com
atuin sync
atuin key
```

Save the password and encryption key in a password manager. On every other host,
log in with the same account and paste Nano's encryption key when prompted:

```sh
atuin login -u carjin
atuin sync
atuin status
```

Use `atuin login` to update an existing host's key: it re-encrypts the local
record store before replacing the key. Do not copy a key file over an existing
one. Keep a backup of `~/.local/share/atuin` before onboarding hosts with
existing history. Run `atuin import auto` on any host whose earlier shell
history has not yet been imported.

Check the service and public endpoint from Nano:

```sh
systemctl status atuin
curl --fail https://anarhizam.org/atuin/healthz
```
