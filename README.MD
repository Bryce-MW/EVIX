# Experimental Virtual Internet Exchange Scripts

This repository contains the scripts used by [EVIX](https://evix.org). A majority of the scripts and configuration used
by EVIX are in this repository. While some parts of our scripts are easily configurable, there are still many areas
where there are hardcoded values. The main example is that almost everything uses `/evix` as the base directory. I would
like to allow relative directories someday but that's not an option quite yet. I am currently moving most config to the
`secret-config.json` file but there are places where that does not exist yet or is not possible. Essentially, what I am
saying is that you can't just download this onto a server and quickly set up a clone of EVIX. This repo doesn't even
have the database DDL available yet. I have mainly made this public for future employers and similar people. Perhaps
someday this will be a drop-in solution but that is not our goal. I will try to add in some documentation here in the
future, if only for the sake of our own volunteers.

Note: You will see quite a few commits from Chris. Few of them are actually from him. He is just the one logged in on
our main server so any commits done from the main server will look like they were from him even if they were from
someone else.

## Documentation / Training

### Connections & ways of connecting

- FMT (aka RS1)
    * IP: 72.52.82.6
    * Connections available: VXLAN, EoIP, OpenVPN, Zerotier, LOCAL
- AMS (aka RS2)
    * IP: 93.158.213.143 (ssh port 5738)
    * Connections available: VXLAN, EoIP, OpenVPN, Zerotier
    * Notes: VXLAN on port 500
- NZ
    * IP: 163.47.131.155
    * Connections available: VXLAN, EoIP, OpenVPN, Zerotier
- ZUR
    * IP: 193.148.250.34
    * Connections available: VXLAN, EoIP, OpenVPN, Zerotier
    * Notes: VXLAN on port 500
- FRA
    * IP: 193.148.249.93
    * Connections available: LOCAL
    * Notes: iFog does those
- VAN
    * IP: -
    * Connections available: LOCAL
    * Notes: Chris does those

- Aliases:
    * ams-ts01.evix.org
    * nz-ts01.evix.org
    * zur-ts01.evix.org
    * fmt-ts01.evix.org

### Database

Each client can have multiple ASNs, each ASN can have multiple IPs. Clients can also have multiple tunnels. Tunnels are
independent of ASNs and IPs which is a bit annoying but allows for any config that people have asked for. Requests are
normally deleted when a tunnel is provisioned but not always so there are a lot of stale requests. I try to delete them
when I see them but there is not much harm in keeping them.

![Database schema](https://fk.ci/3HJbHWm.png?_raw=true)

The /evix/admin/interact script should have most of what you need. You can either enter an ASN on the main menu or go
into view and search by something specific. That will tell you all of the details from the database on that peer.
Including if they can be pinged, if they have a BGP session, if they are monitored, and if they are provisioned. Peers
that are provisioned show up on the website and have BGP sessions.

MySQL treats 1 and 0 as true and false and there’s not an easy way for me to make them display as true and false. But if
you see a 0 or 1, it probably means true or false.

If monitor is false then warning emails won’t be sent and the IP won’t be deprovisioned automatically

Provisioned is true means that the IP is normal, BGP sessions are configured, the IP shows up on the website, etc.

We ping every IP in the system every second. Pingable is true if the IP responded last time pings were sent out (sent
from fmt server).

RS Session is true if the BGP session with the FMT RS is up (only tested daily).

clients # Individual person or company connecting  
id, name, website, contact  
asns # A single ASN  
asn, client_id  
ips # A IP address configured for a specific ASN. Monitor false means that we don't send deprovision messages (people
who don't peer with the RS)  
ip, version, asn, monitor, provisioned  
connections # A tunnel. This is connected to a client, not ASN. Someone can have multiple IPs and use whatever tunnel
they want. Note that the IP column is the remote real IP, not an EVIX IP. Additional_args is a custom port for VXLAN and
the any IPs for Zerotier to automatically assign. Zerotier does not yet have a good way to auto-provision. I will add a
script for that in the future but I have to do it manually for now.  
id, client_id, type, server, tunnel_id, ip, additional_args  
requests # A request from our website. Many people have submitted multiple so you may find a few from the same person
when approving their request. I try to remove them when I see them but it does not really matter.  
id, asn, name, contact, website, tunnel_location, tunnel_type, ipv4

### EVIX Directory

/evix directory on the servers (https://git.discovr.us/EVIX/scripts, the git repo is a bit messed up but mostly works).
This is just an overview. Most of the scripts now have comments at the top describing what they are.

* evix
    * admin # Scripts for humans.
    * config # Some is generated, and some is static so be careful when editing.
        * bird # Config for bird.
        * ccd # OpenVPN config.
        * hosts # Route server IP and hostname used by various scripts. DEPRECATED
        * key-value # Key-value storage for per-tunnel-server config like VXLAN port. DEPRECATED
        * peers # Tunnel config generated from the database.
        * playbooks # Ansible automation.
        * ports # Interfaces to be added to each tunnel-server's bridge at startup. DEPRECATED
        * reboot # Special commands for running on reboot. DEPRECATED but can still be used
    * logs # Mostly used by the root server. Only holds the last log, not historical to not so up too much space. Has
      the EoIP log on tunnel servers which matches mac addresses with tunnel IDs.
    * run # Contains repos that we use.
        * arouteserver # Generates our bird config.
        * bgpq3 # Legacy, probably should be removed.
        * bgpq4 # Gets AS-SET info for bird config.
        * bird-rtrlib-cli-0.1.1 # Not sure on this one.
        * rtrlib-0.3.6 # Not sure on this one either.
        * eoip # The Linux EoIP daemon we use.
        * eoip-single # An alternate EoIP daemon which does not work.
        * IX-Website # The website files.
            * files
                * Documents # Static documents.
            * templates # The main website code.
        * openvpn-ca # The CA that we use for OpenVPN.
            * pki # The certificates.
        * PHPMailer # Sending emails with PHP.
        * ZeroTier # Scripts for creating the moon file for the ZT roots.
    * scripts # Scripts in the base directory are used by both the root server and tunnel-servers
        * root # Scripts run by the root server.
        * ts # Scripts run by the tunnel-servers.

### Logs

Quick description of the logs in `/evix/logs`

* `eoip.log` - only on the tunnel servers, matches mac addresses and remote IPs to tunnel IDs.

* `bird_configure.log` - arouteserver
* `commit_website.log` - the website template system
* `graph_api_pull.log` - website graphs
* `ixp_json_generate.log` - https://evix.org/participants.json
* `peers_table_webpage_generate.log` - https://evix.org/#peers
* `ping.log` we ping every registered IP every second. This logs when changes happen
* `tunnel_server_config_generate.log` - `/evix/config/peers`
* `warn_disconnection.log` - daily warning email sending

### VXLAN Mesh

So the way the VXLAN tunnels work is that FMT, AMS, ZUR, and NZ are in a mesh. So theoretically, if a packet needed to
go from ZUR to NZ, they would go directly. Even if there was some edge case where a node didn’t know what other node to
send a packet to, it would just send it to all of them. I don’t understand how this prevents loops but it does. Maybe
because I have stp on.

FRA and VAN are not in the mesh. FRA has a VXLAN tunnel to AMS and VAN has a VXLAN tunnel to FMT. This is because they
are not full evix nodes. They don’t have /evix synced to them and are not in /evix/config/hosts.

### Adding a new location

It should be pretty easy to add a new location.

- Install required software: JQ, OpenVPN, optional bat/batcat (called different things depending on Ubuntu version)
- Add the main server’s ssh key to root (ensure root logon is enabled)
- add a new entry to `/evix/secret-config.json`, add a new entry to `/evix/config/ansible/ansible.cfg` or whatever
  that’s called
- run `/evix/reboot.sh` on all the existing route servers, and the new one once it syncs
- update the database schema to allow that location in the enum
- update the website form to allow that location to be selected
- update the interact script to allow selecting that location for provisioning a new tunnel
- update the ixp json script to add the new location to our export (both in the header and in the nested ifs for adding
  its id to a connection)
- update `/evix/config/arouteserver/general.yml` to add a new custom community for the new location
- add symlinks for relevant parts of `/evix/config/symlinks.sh`

Ok, that’s more complex than I had expected but not terrible. Some of this should be automated more in the future.
Perhaps put the locations in the database and generate config or use it from there directly.

### PeeringDB

For PeeringDB, they pull https://evix.org/participants.json which is generated by
/evix/scripts/root/ixp_json_generate.sh. HE also uses it for https://bgp.he.net/exchange/EVIX

### Scripts

I recommend checking out crontab -e. Then you can see all the scripts that are run automatically. I’ve commented them
decently, but I do agree that better docs would be good.

### ZeroTier

For ZeroTier, it currently has to be done manually using a script on the ZeroTier server. I would like to add a script
on the root server to do it which should not be hard

### Provisioning Rules

Yea, so if someone’s bird connection is down for 14 days, provisioned is set to false. This means that their tunnel is
still enabled but their bird session is not. We keep their IPs allocated to them in case they come back where we can
re-enable them. To re-enable set provisioned to true. If you don’t want it to be disabled again automatically, then you
can also set monitored to false. Monitored is automatically set back to true once they are seen again. I know that’s
weird but it used to work differently and make more sense but because we had so much legacy data, this was the way to
keep the database the cleanest.

### Some thoughts

I do want to do this eventually but I want to change how the config works first. My vision is that each tunnel server
would connect to the main server and generate a JSON config based on the database. It would also generate a JSON config
based on the existing config. It could then use these to find the differences and apply those changes. That’s a lot down
the line but it’s what I would want to do before upgrading anything else to a full node. Also making it so that on the
website, you can only select the types of tunnels actually offered at a particular location.