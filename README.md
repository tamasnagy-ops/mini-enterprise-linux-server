# Mini Enterprise Linux Server

Home lab where I build and run a small Linux server the way it would be done in a company.
I'm a former welder (12 years) with an HTL background in electronics and technical informatics,
moving into Linux system administration.

## Environment
- Host: Debian (Acer Nitro 5)
- Virtualization: KVM / libvirt
- Remote access: Tailscale

## What's done
| Area | What I set up |
|---|---|
| Admin user | Daily work as a non-root user with sudo |
| Web server | Nginx, enabled at boot |
| Firewall | ufw (nftables backend): only SSH, HTTP and Plex open; Plex restricted to the LAN |
| Custom service | Bash heartbeat script run by systemd under a dedicated service user, from /opt, with auto-restart; logs in journald |
| Media server | Plex Media Server, LAN-only |
| Scripting | USB hardware-key access script (see below) |
| Permissions | Exercises with file permissions and a shared group folder |

## Featured script: USB hardware key
Opens a protected file only when one specific USB stick is plugged in.
- Two checks: USB vendor/product ID (`lsusb`) and filesystem UUID (`lsblk -f`)
- `status` mode for diagnostics
- Audit log with timestamps for allowed and denied access
- Clear exit codes

Known limits: the UUID and the vendor/product ID can be copied to another stick,
so this is access control by script, not encryption.

## Planned
- [x] SSH key-based login, password login disabled
- [ ] Automated backup with cron or a systemd timer
- [ ] Bash health-check script (disk, memory, services)
- [ ] Ansible playbook to rebuild this setup automatically
- [ ] AlmaLinux VMs for RHCSA practice
