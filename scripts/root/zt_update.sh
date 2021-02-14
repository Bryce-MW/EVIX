#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson 2021-02-12
#  * 2021-02-13|>Bryce|>Finished the script

export token="***REMOVED***"
export root_ip="23.129.32.56"
export network="***REMOVED***"
export auth="X-ZT1-Auth: $token"
export member="http://$root_ip:9993/controller/network/$network/member"

edit () {
  id=$(jq --null-input --raw-output --argjson value "$1" '$value | .zt')
  del=$(jq --null-input --raw-output --argjson value "$1" '$value | .post.authorized == false')
  jq --null-input --compact-output --argjson value "$1" '$value | .post' |
  curl -X POST --header "$auth" -d @- "$member/$id" 2>/dev/null |
  jq --slurp --raw-output 'sort_by([.authorized, .bridge, (.vMajor > -1), .address]) | .[] | .address + ": " + ([(if .authorized then "Authorized" else empty end), (if .activeBridge then "Bridge" else empty end), (if .vMajor > -1 then "V" + (.vMajor | tostring) + "." + (.vMinor | tostring) + "." + (.vRev | tostring) else "Hasn’t been seen since last reboot" end), (if (.ipAssignments | length) > 0 then "IPs: " + (.ipAssignments | join(", ")) else empty end)] | join(", "))'
  if [ "$del" == "true" ]; then
    curl -X DELETE --header "$auth" "$member/$id" >/dev/null 2>&1
  fi
}
export -f edit

{
  mysql --user evix --password=***REMOVED*** --reconnect -B -N evix 2>/dev/null <<<"SELECT ip, additional_args FROM connections WHERE type='zerotier';" |
  jq --slurp --compact-output --raw-input 'split("\n") | map(split("\t") | if length > 0 then [.[0], (.[1] | split(" "))] else empty end)' &

  curl -X GET --header "$auth" "$member" 2>/dev/null;
} |
jq --slurp --compact-output '[.[0], (.[1] | keys)] | {remove: (.[1] - (.[0] | map(.[0]))), add: .[0]} | (.remove | .[] | {zt: ., post: {"authorized": false, "activeBridge": false, "ipAssignments": []}}), (.add | .[] | {zt: .[0], post: {"authorized": true, "activeBridge": true, "ipAssignments": .[1]}})' |
xargs -P 0 -d "\n" -I {} bash -c "edit '{}'" edit
