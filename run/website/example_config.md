# Connecting to EVIX

EVIX supports the following methods and locations for peering:

- Direct Connection via [iFog](https://ifog.ch/en/ip/ixp-access) (Zurich, Frankfurt) or [Free Range Cloud](https://freerangecloud.com/) (Fremont, Vancouver)
- Layer 2 Tunnel (Fremont, Amsterdam, Zurich, Auckland)

Official OS support is currently limited to Debian, VyOS and Mikrotik routerOS, however, these instructions should be transferable to other Linux-based systems as well.

[TOC]

## Configuring tunnels

In case you don't have a direct connection to EVIX, here are some instructions on how to configure your tunnel.

### OpenVPN + VyOS

*NOTE: Only VyOS 1.18 is supported. The rolling .12 release breaks OpenVPN bridging*

VyOS seems to have poor support for IPv6 on its OpenVPN interfaces so our solution is to create an OpenVPN TAP connection and bridge it to a standard Linux bridge which holds all the IP configuration. When looking at the config instructions you should pay attention to three addresses, your IPv4 address, your IPv6 address and your server address. The server address is the address of the closest EVIX virtual switch to yourself geographically.

You may use the following config snippet to configure your VyOS router, ensure that you have changed anything encased in `<>` brackets:

```
set interfaces bridge br0 address '<Your IPv6 Address>'
set interfaces bridge br0 address '<Your IPv4 Address>'
set interfaces bridge br0 aging '300'
set interfaces bridge br0 hello-time '2'
set interfaces bridge br0 max-age '20'
set interfaces bridge br0 priority '0'
set interfaces bridge br0 stp 'false'
set interfaces openvpn vtun0 bridge-group bridge 'br0'
set interfaces openvpn vtun0 device-type 'tap'
set interfaces openvpn vtun0 mode 'client'
set interfaces openvpn vtun0 protocol 'udp'
set interfaces openvpn vtun0 remote-host '<Server Address>'
set interfaces openvpn vtun0 tls ca-cert-file '/config/auth/openvpn/ca.crt'
set interfaces openvpn vtun0 tls cert-file '/config/auth/openvpn/<your certificate>.crt'
set interfaces openvpn vtun0 tls key-file '/config/auth/openvpn/<your key>.key'
set interfaces openvpn vtun0 'use-lzo-compression'
set protocols bgp <Your ASN> neighbor 206.81.104.1 remote-as '137933'
set protocols bgp <Your ASN> neighbor 206.81.104.1 soft-reconfiguration 'inbound'
set protocols bgp <Your ASN> neighbor 2602:fed2:fff:ffff::1 address-family ipv6-unicast soft-reconfiguration 'inbound'
set protocols bgp <Your ASN> neighbor 2602:fed2:fff:ffff::1 remote-as '137933'
```

Note that you will need to create the directory `/config/auth/openvpn` and place the `ca.crt` and your certificate and private key files here. These files will be provided when you join EVIX.

### OpenVPN + Debian/Ubuntu

Connecting to EVIX via Debian should be fairly straightforward, simply install OpenVPN via `apt` and place the ca, certificate and key in the `/etc/openvpn` folder. These files will be provided when you join EVIX.

Then create a `client.conf` file containing the following:

```
client
dev tap
proto udp

remote <Server IP> 1194
resolv-retry infinite
nobind
persist-key
persist-tun

ca ca.crt
cert as_65530.crt
key as_65530.key

remote-cert-tls server
comp-lzo
verb 3
```

Enable the service by running `systemctl enable openvpn@client` and start it by running `systemctl start openvpn@client`. After a few seconds verify the tunnel has come up with `ip addr`.

### Mikrotik RouterOS

EVIX also supports connection via EoIP tunnels on Mikrtoik RouterOS. To connect, you will need to provide your router's public IP address. Note that your tunnel ID will be provided to you when you join EVIX. The configuration commands are as follows:

```
/interface eoip add !keepalive local-address=<Your public IP> name=EVIX remote-address=<Server IP> tunnel-id=<ID> 
/routing bgp instance set default as=<Your ASN> disabled=no
/routing bgp peer add instance=default name=EVIX remote-address=206.81.104.1 remote-as=137933 ttl=default
/routing bgp peer add instance=default name=EVIX remote-address=2602:fed2:fff:ffff::1 remote-as=137933 ttl=default
```

*Please note that we do not support EoIP keepalives so be sure to disable them.*

### EoIP and Linux

In case you feel adventurous, you can also use an EoIP tunnel on Linux to connect to EVIX. We recommend using the inofficial EoIP kernel module by Boian Bonev: https://github.com/bbonev/eoip.

After compiling the kernel modules and the userland management utility `eoip` run the following commands to create the tunnel:

```
cd <path-to-eoip-utility>
./eoip add name eoip-evix local <your-local-ip> remote <evix-tunnel-server-ip> tunnel-id <tunnel-id>
ip link set eoip-evix up
ip addr add 206.81.104.x/24 dev eoip-evix
ip addr add 2602:fed2:fff:ffff:x::xx/64 dev eoip-evix
```

Your tunnel ID will be provided to you when you join EVIX.

### ZeroTier

ZeroTier is a new VPN protocol designed to be zero configuration. ZeroTier is especially advantageous in that it can automatically establish tunnels to other ZeroTier users, bypassing the EVIX switch and establishing a lower-latency connection with other peers.

While the standard implementation of ZeroTier relies on ZeroTier’s root servers, EVIX has opted to create our own route servers to maintain independence. Fortunately, the configuration steps are not much different from Vanilla ZeroTier.

First install ZeroTier using the official documentation: https://www.zerotier.com/download.shtml 

Once the install has completed:

```sh
cd /var/lib/zerotier-one
mkdir moons.d
cd moons.d
wget https://evix.org/static/0000002cb385e495.moon
systemctl restart zerotier-one
```

Now, verify you can see the EVIX root node by running `zerotier-cli listpeers`, you should see something like:

```
200 listpeers <ztaddr> <path> <latency> <version> <role>
200 listpeers 2cb385e495 23.129.32.56/9993;4115;4115 207 1.2.12 MOON
200 listpeers 8841408a2e 46.101.160.249/9993;1538759940976;4306 17 1.1.5 PLANET
200 listpeers 9d219039f3 188.166.94.177/9993;1538759940976;4091 2 1.1.5 PLANET
```

The key is to see that the EVIX root server is listed as a moon. Once you have confirmed this, simply run: `zerotier-cli join 2cb385e4952b3e84` to join the network. Tell us your ZeroTier ID (`zerotier-cli info`) and your membership will be approved by one of our staff. 

Afterwards you should be able to see the zerotier network interface `ztzatk5wqr` and assign your EVIX IPs using the `ip` command:

```
ip addr add 206.81.104.x/24 dev ztzatk5wqr
ip addr add 2602:fed2:fff:ffff:x::xx/64 dev ztzatk5wqr
```

### VXLAN

Virtual eXtensible Local Area Network (VXLAN) is an extension to Virtual Local Area  Network (VLAN). It encapsulates a Layer 2 Ethernet frame into a UDP  packet and transmits the packet over a Layer 3 network. Make sure to use a Linux kernel newer than version 3.12 since you may run into issues with IPv6 networking on older versions.

*Note: The default port for VXLAN is 4789 but for technical reasons we use **port 500** instead **for Amsterdam and Zurich**.*

To create a VXLAN tunnel, run the following commands:

```
ip link add vxlan-evix type vxlan id <your-tunnel-id> local <your-local-ip> remote <evix-tunnel-server-ip> dstport <vxlan-port> dev eth0
ip link set vxlan-evix up
ip addr add 206.81.104.x/24 dev vxlan-evix
ip addr add 2602:fed2:fff:ffff:x::xx/64 dev vxlan-evix
```

Replace the VXLAN ID, remote address and interface IP with the information provided by EVIX. If needed, replace `eth0` with your server's primary interface.

## Establishing your BGP sessions

We run two route servers and strongly recommend connecting to both of them:

| Name             | ASN    | IPv4             | IPv6                      |
| ---------------- | ------ | ---------------- | ------------------------- |
| RS 1 (Fremont)   | 137933 | `206.81.104.1`   | `2602:fed2:fff:ffff::1`   |
| RS 2 (Amsterdam) | 209762 | `206.81.104.253` | `2602:fed2:fff:ffff::253` |

### Bird

> **Help wanted!** 
>
> Do you run Bird on EVIX? We'd appreciate if you would provide us with your (example) config so we can add it to this document: helpdesk@evix.org

### Bird 2

If you run Bird 2, the following example config provided by @Nicholis (many thanks!) can serve as a starting point.

You probably already have a method of exporting your routes, and should easily be able to adapt the below configuration to work with that. For the purposes of this example, it is assumed that you have your prefixes defined in the static protocol `my_routes`, and have an export filter called `export_my_routes`. All you need to do is to modify the `my_routes` protocol to your prefixes, and replace `65001` with your ASN.

```
protocol static my_routes {
        ipv6;
        route 2001:db8:1::/48 reject;
        route 2001:db8:2::/48 reject;
}

filter export_my_routes {
        if proto = "my_routes" then {
                accept;
        }
        reject;
}

protocol bgp evix_01_v6 {
       local as 65001;
       neighbor 2602:fed2:fff:ffff::1 as 137933;

        ipv6 {
                 import all;
                 export filter export_my_routes;
        };
}

protocol bgp evix_02_v6 {
       local as 65001;
       neighbor 2602:fed2:fff:ffff::253 as 209762;

        ipv6 {
                 import all;
                 export filter export_my_routes;
        };
}
```

### Quagga/frr

> **Help wanted!** 
>
> Do you run Quagga or frr on EVIX? We'd appreciate if you would provide us with your (example) config so we can add it to this document: helpdesk@evix.org

### Mikrotik

> **Help wanted!** 
>
> Do you run Mikrotik RouterOS on EVIX? We'd appreciate if you would provide us with your (example) config so we can add it to this document: helpdesk@evix.org

## Some helpful troubleshooting steps:

* Can you ping your IPv6 gateway address?
* Can you ping the IPv6 route server (`2602:fed2:fff:ffff::1`)?
* Can you ping the IPv4 route server (`206.81.104.1`)?
* Display IPv4/IPv6 routes: `ip route`/`ip -6 route`
* Display BGP session information: `show ip bgp summary`
* Display received routes: `show ip bgp neighbors <Neighbor IP> received-routes`
* Display advertised routes: `show ip bgp neighbors <Neighbor IP> advertised-routes`
* Use our Looking Glass to check your BGP session: https://lg.evix.org/

If you still have issues connecting to EVIX, please reach out to us:

- Discord: [discord.gg/dXVpp6d](https://discord.gg/dXVpp6d)
- Email: [helpdesk@evix.org](mailto:helpdesk@evix.org)