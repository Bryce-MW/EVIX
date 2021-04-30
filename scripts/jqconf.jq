def zt_parse_members:
    sort_by([
        .authorized,
        .bridge,
        (.vMajor > -1),
        .address]) # Sort members by those authorized first, then those that are bridges (should be all of them)
                   # then by if their major version is greater than -1 (basically if we have seen them at all) then by
                   # their address as a last resort
    | .[] # Separate the members into elements
    | .address # Format the members starting with their address
      + ": " # then a colon and space
      + (
          [
              (if .authorized then "Authorized" else empty end), # then specify if they are authorized
              (if .activeBridge then "Bridge" else empty end), # then if they are a bride
              (if .vMajor > -1 then
                  "V" + (.vMajor | tostring) + "." + (.vMinor | tostring) + "." + (.vRev | tostring) # Then their
                                                                                                     # version
                else
                    "Hasn’t been seen since last reboot" # or this message if they have not been seen
                end),
              (if (.ipAssignments | length) > 0 then # if they have any IPs
                  "IPs: " + (.ipAssignments | join(", ")) # list them all comma separated
                else
                    empty
                end)
          ]
          | join(", ") # Separate each of these previous sections by a comma (this is done last in case some sections
                       # don't exist
      )
;

def zt_parse_member:
    .address # Provide their address,
    + ": "
    + (
        [
            (if .authorized then "Authorized" else empty end), # if they are authorized,
            (if .activeBridge then "Bridge" else empty end), # if they are a bridge,
            (if .vMajor > -1 then # if their version is not negative (negative means they haven't connected),
                "V" + (.vMajor | tostring) + "." + (.vMinor | tostring) + "." + (.vRev | tostring) # then version,
              else "Hasn’t been seen since last reboot" # otherwise we say that we haven't seen them,
              end),
            (if (.ipAssignments | length) > 0 then "IPs: " + (.ipAssignments | join(", ")) else empty end) # their IPs.
        ]
        | join(", ") # Comma separate the fields
    )
;

def zt_parse_peer_time($member):
    map(if .address == $member then . else empty end) # Find the specific member that we are looking for
    | .[0]? # Get the first (only) result if it exists
    | .paths # Look specifically at the paths which are the ways that we can reach this peer
    | map(
        if .preferred == true then # We want to look specifically at the preferred or main path to this peer
          (
              .lastReceive / 1000 # The last receive time is in milliseconds so we convert to unix timestamp
              | gmtime # Convert the timestamp into an array of the date elements
              | (.[0] | tostring) # The first element is the year
                + "-"
                + (["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"][.[1]])
                  # The second element is the month which I convert to a month abbreviation since that's easier to
                  # read
                + "-"
                + (.[2] | tostring) # The third element is the day. I don't need any more subdivisions than this
          )
        else empty end
    )
    | .[0]
;

def zt_create_world($type):
  {
    id: "0000002cb385e495",
    objtype: "world",
    roots: .roots,
    signingKey: "e433b98dace0cb4822b9b406e516595feba60868c44dd9cef6ab7f50c47a3a38a4a703903e82aed8fb8c3cde2b572a77edfa7d63ff0ff130a345f41a8097ed67",
    signingKey_SECRET: .key,
    updatesMustBeSignedBy: "e433b98dace0cb4822b9b406e516595feba60868c44dd9cef6ab7f50c47a3a38a4a703903e82aed8fb8c3cde2b572a77edfa7d63ff0ff130a345f41a8097ed67",
    worldType: $type
  }
;

def graph_get_ids:
  .hosts # Grab the posts
  | to_entries[] # Get key value pairs
  | (.value.monitor_id // empty | tostring) # Get the monitor IDs if there is one or nothing otherwise
    + " "
    + (.value.short_name) # Get the short name (i.e fmt, ams, etc)
;

def ixp_json_format:
  map(select(.asns | length > 0)) # Member must have at least one ASN
  | map((. + {asn: .asns[]}) | del(.asns)) # Make a separate entry for each ASN
  | map(select([.asn.ips[].provisioned] | any(. == 1))) # Only select those with at least one ASN
  | map(
    {
      asnum: .asn.asn,
      member_type: "peering",
      name: .name,
      url: .website,
      peering_policy: (if [.asn.ips[].monitor] | any(. == 1) then "open" else "selective" end),
        # Non monitored IPs are considered selective since they don't require RS sessions in our system
      contact_email: [.contact], # This field is an array for some reason
      connection_list:
        [
          {
            ixp_id: 756,
            state: "active", # This is a long story that will need fixing. Needs to be provisional not operational.
            if_list:
              [
                .tunnels // [] # Get the list of tunnels if any
                | .[] # Address them individually
                | {
                  switch_id: {fmt: 1, ams: 2, zur: 3, nz: 4, van: 5, fra: 6}[.server], # Use a key lookup to find the
                    # switch ID. This should be automated in the future
                  if_speed: 1000, # Assume 1GBps for all
                  if_type: .type
                }
              ],
            vlan_list:
              [
                (.asn.ips // [] | map(select(.provisioned == 1)) # Find all provisioned IPs
                | (map(select(.version == 4)) | .[] | {vlan_id: 0, ipv4: {address: .ip, max_prefix: 100, routeserver: (.monitor == 1)}}), # Pick out and format IPv4
                  (map(select(.version == 6)) | .[] | {vlan_id: 0, ipv6: {address: .ip, max_prefix: 100, routeserver: (.monitor == 1)}})) # Pick out and format IPv6
              ]
          }
        ]
    }
  )
  | .
  + [
    (
      ( # Difference in configuration for our route servers
        {
          asn: 137933,
          name: "Route Server",
          switch_id: 1,
          address: "206.81.104.1",
          address_6: "2602:fed2:fff:ffff::1"
        },
        {
          asn: 209762,
          name: "Backup Route Server",
          switch_id: 1,
          address: "206.81.104.253",
          address_6: "2602:fed2:fff:ffff::253"
        }
      )
      | { # The rest of the configuration to insert that into
        asnum: 137933,
        member_type: "ixp",
        name: "Route Server",
        url: "https://evix.org",
        peering_policy: "open",
        peering_policy_url: "https://evix.org/#faq",
        contact_email: ["helpdesk@evix.org"],
        contact_hours: "Whenever our volunteers have time. Please be patient.",
        connection_list:
          [
            {
              ixp_id: 756,
              state: "active",
              if_list: [{switch_id: 1, if_speed: 1000}],
              vlan_list:
                [
                  {
                    vlan_id: 0,
                    ipv4:
                      {
                        address: "206.81.104.1",
                        routeserver: true,
                        as_macro: "AS-EVIX",
                        max_prefix: 1000000,
                        services:
                          [
                            {
                              type: "ixrouteserver",
                              os: "Ubuntu",
                              os_version: "20.04",
                              deamon: "bird",
                              daemon_version: "1.6.4"
                            }
                          ]
                      },
                    ipv6:
                      {
                        address: "2602:fed2:fff:ffff::1",
                        routeserver: true,
                        as_macro: "AS-EVIX",
                        max_prefix: 1000000,
                        services:
                          [
                            {
                              type: "ixrouteserver",
                              os: "Ubuntu",
                              os_version: "20.04",
                              deamon: "bird",
                              daemon_version: "1.6.4"
                            }
                          ]
                      }
                  }
                ]
            }
          ]
      }
    )
  ]
  | { # The overall format that this is all added to
    version: "1.0",
    timestamp: (now | todateiso8601),
    ixp_list:
      [
        {
          ixp_id: 756,
          shortname: "EVIX",
          name: "Experimental Virtual Internet Exchange",
          url: "https://evix.org/",
          country: "CA",
          ixf_id: 756,
          support_email: "helpdesk@evix.org",
          support_contact_hours: "Whenever our volunteers have time. Do not expect speedy responses.",
          peering_policy_list: ["open", "selective"],
          vlan:
            [
              {
                id: 0,
                name: "Peering VLAN",
                ipv4:
                  {
                    prefix: "206.81.104.0",
                    masklen: 24,
                    looking_glass_urls: ["https://lg.evix.org/alice/routeservers/0", "https://lg.evix.org/alice/routeservers/2"]
                  },
                ipv6:
                  {
                    prefix: "2602:fed2:fff:ffff::",
                    masklen: 64,
                    looking_glass_urls: ["https://lg.evix.org/alice/routeservers/1", "https://lg.evix.org/alice/routeservers/3"]
                  }
              }
            ],
          switch:
            [
              {
                id: 1,
                name: "Fremont, CA, United States",
                pdb_facility_id: 547,
                city: "Fremont",
                country: "US",
                software: "Ubuntu"
              },
              {
                id: 2,
                name: "Amsterdam, The Netherlands",
                pdb_facility_id: 857,
                city: "Dronten",
                country: "NL",
                software: "Ubuntu"
              },
              {
                id: 3,
                name: "Zurich, Switzerland",
                city: "Zurich",
                country: "CZ",
                software: "Ubuntu"
              },
              {
                id: 4,
                name: "Auckland, New Zealand",
                city: "Auckland",
                country: "NZ",
                software: "Ubuntu"
              },
              {
                id: 5,
                name: "Vancouver, BC, Canada",
                city: "Vancouver",
                country: "CA",
                software: "Ubuntu"
              },
              {
                id: 6,
                name: "Frankfurt, Germany",
                city: "Frankfurt",
                country: "DE",
                software: "Ubuntu"
              }
            ]
        }
      ],
    member_list: .
  }
;

def parse_bird:
  split("\n\n") # Splits each protocol
  | map(split("\n"))[] # Splits the protocol into lines
  | (.[0] | split(" ") | map(if . == "" then empty else . end) # Get the separate words and remove empty spaces
    | {
      name: .[0],
      type: .[1],
      status: .[3],
      since: (.[4] + "T" + .[5] + "Z" | fromdate), # Format the date in a way that fromdate allows
    }
  ) + {all: .[1:]}
  | reduce .all[] as $item # Go through each line and parse it into the object
    (.;
      if $item | startswith("  Description:") then
        . + {description: $item[18:]}
      elif $item | startswith("  Preference:") then
        . + {preference: $item[18:] | tonumber}
      elif $item | startswith("  Input filter:") then
        . + {in_filter: $item[18:]}
      elif $item | startswith("  Output filter:") then
        . + {out_filter: $item[18:]}
      elif $item | startswith("  Import limit:") then
        . + {route_limit: $item[18:] | gsub("\\[HIT\\]"; "") | tonumber} # Just get number, ignore if hit
      elif $item | startswith("  Routes:") then
        .
        + {
          routes: $item[18:]
            | split(" ") # Split up route information
            | {
              imported: .[0] | tonumber, # These basically can allow some of these fields to not be present. I can't
                # remember exactly which ones are allowed to disappear but I did figure it out and get them working
                # properly
              filtered: (if .[3] == "filtered," then .[2] | tonumber else 0 end),
              exported: (if .[5] == "exported," then .[4] | tonumber else .[2] | tonumber end),
              preferred: (if .[7] == "preferred" then .[6] | tonumber else .[4] | tonumber end)
            }
        }
      elif $item | startswith("  BGP state:") then
        . + {state: $item[22:]}
      elif $item | startswith("    Neighbor address:") then
        . + {neighbor_address: $item[22:]}
      elif $item | startswith("    Neighbor AS:") then
        . + {neighbor_asn: $item[22:] | tonumber}
      elif $item | startswith("    Neighbor caps:") then
        . + {capabilities: $item[22:] | split(" ")}
      elif $item | startswith("    Session:") then
        . + {session_type: $item[22:] | split(" ")}
      elif $item | startswith("    Source address:") then
        . + {source_address: $item[22:]}
      elif $item | startswith("    Hold timer:") then
        . + {hold_timer: $item[22:] | split("/") | map(tonumber) | {current: .[0], max: .[1]}}
      elif $item | startswith("    Keepalive timer:") then
        . + {state: $item[22:] | split("/") | map(tonumber) | {current: .[0], max: .[1]}}
      elif $item | startswith("    Last error:") then
        . + {last_error: $item[22:]}
      else
        . # Ignore any lines that we haven't written parsing for yet
      end
    )
  | del(.all) # Remove the set of lines that we just parsed
;

def determine_down:
  reduce
    .[] # We slurped up entries to get this
  as
    $item
    (
      {}; # Start with an empty object
      .[$item.status.neighbor_address // empty] # Get the existing entry for an address. Ignore protocols with no
        # address (like device protocols). I probably should select BGP protocols first but it's not a big deal
      |= (. // []) + [$item] # Update that entry by appending to the list. Or start a new list if there was no entry
    )
  | to_entries[] # We want key value pairs since we are done with the grouping
  | {
    ip: .key, # Since we no longer are using a dictionary, we need the IP
    up: (.value | any(.status.status == "up")), # An IP will be considered up if any RS is up
    down: (.value | map(select(.status.status != "up"))) # Only include the down entries
  }
;

def peer_pairs:
  reduce
    .[] # We slurped up entries to get this
  as
    $item
    (
      {}; # Start with an empty object
      .[$item.status.neighbor_address // empty] # Get the existing entry for an address. Ignore protocols with no
        # address (like device protocols). I probably should select BGP protocols first but it's not a big deal
      |= (. // []) + [$item] # Update that entry by appending to the list. Or start a new list if there was no entry
    )
  | to_entries # We want key value pairs since we are done with the grouping
  | map({
    ip: .key, # Since we no longer are using a dictionary, we need the IP
    up: (.value | any(.status.status == "up")), # An IP will be considered up if any RS is up
    sessions: .value # Include all pairs this time
  })
  | reduce
    .[] # Go through each item
  as
    $item
    (
      {}; # Start with an empty object
      .[$item.sessions[0].status.neighbor_asn // empty | tostring]
        [if $item.sessions[0].status.neighbor_address // empty | contains(":") then "v6" else "v4" end] # Get the existing entry for an ASN and
        # IP version. Ignore weird things
      |= (. // [] ) + [$item]
    )
;

def compute_zt_diff:
  [ # Get all the info from the database and just thee keys from the API
    .[0],
    (.[1] | keys)
  ]
  | { # Compute the diff of those to add and remove
    remove: (.[1] - (.[0] | map(.[0]))),
    add: .[0] # Since adding a user twice does nothing, we don't use a diff, just ensure they are all actually added
  }
  | (
    .remove
    | .[]
    | {
      zt: .,
      post: {
        authorized: false,
        activeBridge: false,
        ipAssignments: []
      }
    }
  ),
  (
    .add
    | .[]
    | {
      zt: .[0],
      post:
        {
          authorized: true,
          activeBridge: true,
          ipAssignments: .[1]
        }
      }
  )
;

def parse_eoip_cmdline:
  split("\u0000") # Args are null separated
  | .[5:] # Remove the redundant ones
  | reduce .[] as $item ([]; # Go through them all and match up pairs
    if (.[-1] | length) == 1 then # If the last item is not paired
      .[:-1] + [[.[-1][0], $item]] # Then we keep all before the last item and add the new pair
    else
      . + [[$item]] # Otherwise we start a new pair
    end
  )
  | map({id: .[1], ip: .[0]})
;

def parse_eoip_config:
  split("\n") # Grab all of the lines
  | map(select(length > 0)) # Only use lines that are not blank. This is mainly to exclude the blank last line
  | map(split(" "))
  | map({id: .[0], ip: .[1]})
;

def parse_ip_vxlan:
  map(if .linkinfo.info_kind == "vxlan" and (.ifname | startswith("vtep")) then . else empty end)
    # Choose only vtep interfaces
  | map({
    id: .linkinfo.info_data.id,
    ip: (.linkinfo.info_data.remote // .linkinfo.info_data.remote6), # Choose either IP or IPv6
    port: .linkinfo.info_data.port
  })
;

def parse_config_vxlan($port):
  split("\n") # Get the lines of the config
  | .[:-1] # Ignore the blank line at the end
  | map(split(" ")) # Get each of the fields
  | map({
    id: .[0] | tonumber,
    ip: .[1],
    port: (if .[2] == "" or .[2] == null then $port else .[2] | tonumber end)
      # If the port is not listed, use the default
  })
;

def diff_vxlan($ip; $ipv6; $bridge):
  {existing: .[0], new: .[1]} # Get the new and existing config
  | {delete: (.existing - .new), add: (.new - .existing)} # Calculate diffs
  | (.delete[] | "link delete vtep\(.id)"), # Create the delete syntax
    (
      .add[]
      | "link add vtep\(.id) "
      + "type vxlan id \(.id) "
      + "local \(if .ip | test("[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+") then $ip else $ipv6 end) "
        # Use local IP if remote is IP. Otherwise use IPv6
      + "remote \(.ip) "
      + "dstport \(.port)\n"
      + "link set up vtep\(.id)\n"
      + "link set vtep\(.id) "
      + "master \($bridge)" # Ensure that it is enslaved to the bridge
    )
;
