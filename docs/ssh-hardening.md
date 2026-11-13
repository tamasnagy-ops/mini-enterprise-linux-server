# SSH Hardening

## Goal

Secure SSH access to my Debian lab server:

- log in with an SSH key instead of a password
- no password login and no root login over SSH
- SSH reachable only through my Tailscale network, not from the LAN or the internet

## Setup

| Role   | Machine                        | Address          |
|--------|--------------------------------|------------------|
| Server | Debian 13 laptop (Acer Nitro 5) | `100.119.9.63` (Tailscale) |
| Client | Windows laptop (MSI)           | `100.84.145.105` (Tailscale) |

## Steps

### 1. Create a key pair on the client

The key pair is created on the **client**, so the private key never has to leave it.

```powershell
ssh-keygen -t ed25519 -C "tamas@msi"
```

- `id_ed25519` = private key, stays on the client, protected with a passphrase
- `id_ed25519.pub` = public key, goes to the server

### 2. Install the public key on the server

Windows has no `ssh-copy-id`, so I added the key by hand:

```bash
nano ~/.ssh/authorized_keys      # paste the whole line: ssh-ed25519 AAAA... tamas@msi
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

SSH ignores the key if these files are readable or writable by others.

### 3. Test key login

In a new terminal (old session kept open as a fallback):

```powershell
ssh nagyt@100.119.9.63
```

It asked for the key passphrase, not the account password. The server log confirms it:

```bash
sudo journalctl -u ssh --since "10 minutes ago"
```

```
Accepted publickey for nagyt from 100.84.145.105 port 53842 ssh2: ED25519 SHA256:oFrGSerGh5...
```

The fingerprint matches the one shown by `ssh-keygen`.

### 4. Disable password and root login

I put my settings in a drop-in file instead of editing the main config:

```bash
sudo nano /etc/ssh/sshd_config.d/10-hardening.conf
```

```
PasswordAuthentication no
PermitRootLogin no
```

Test the config before restarting, then check the settings sshd actually uses:

```bash
sudo sshd -t                     # no output = valid
sudo systemctl restart ssh
sudo sshd -T | grep -i -E 'passwordauth|permitroot'
```

### 5. Prove password login is refused

```powershell
ssh -o PubkeyAuthentication=no nagyt@100.119.9.63
```

```
nagyt@100.119.9.63: Permission denied (publickey).
```

`(publickey)` is the list of allowed login methods. Only keys are left.

### 6. Limit SSH to Tailscale with ufw

Before, ufw allowed SSH from anywhere. I added the new rule first, tested it, and only then removed the old rules:

```bash
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw status numbered
sudo ufw delete 5                # OpenSSH (v6) Anywhere
sudo ufw delete 1                # OpenSSH Anywhere
```

I deleted the higher number first, because deleting a rule moves all rules below it up by one.

Result:

```
[ 1] Nginx HTTP                 ALLOW IN    Anywhere
[ 2] 32400/tcp                  ALLOW IN    192.168.0.0/24    # Plex LAN
[ 3] 22/tcp on tailscale0       ALLOW IN    Anywhere
[ 4] Nginx HTTP (v6)            ALLOW IN    Anywhere (v6)
[ 5] 22/tcp (v6) on tailscale0  ALLOW IN    Anywhere (v6)
```

Test:

```powershell
ssh nagyt@100.119.9.63           # via Tailscale: works
ssh nagyt@192.168.0.159          # via LAN: Connection timed out
```

"Timed out" means the firewall drops the connection silently instead of answering.

## What I learned

- Always create the key on the client. Check the prompt to see which machine you are on.
- The public key line needs all three parts: type, key, label.
- Keep an SSH session open while changing the SSH config or the firewall.
- Test with `sshd -t` before restarting the service.
- In `sshd_config.d/`, the first value sshd finds wins, so check the folder for existing files first.
- Add the new firewall rule and test it before deleting the old one.

## Next steps

- `ufw limit` for brute-force protection
- automated backups with cron
