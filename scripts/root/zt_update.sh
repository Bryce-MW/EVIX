#! /bin/bash
# NOTE(bryce): Written by Bryce Wilson 2021-02-12
#  * 2021-02-13|>Bryce|>Finished the script
#  * 2021-04-16|>Bryce|>Added JSON config

token=$(jq -r '.zt.auth_token' /evix/secret-config.json)
export token
root_ip=$(jq -r '.zt.root_ip' /evix/secret-config.json)
export root_ip
network=$(jq -r '.zt.network_id' /evix/secret-config.json)
export network
export auth="X-ZT1-Auth: $token"
export member="http://$root_ip:9993/controller/network/$network/member"

user=$(jq -r '.database.user' /evix/secret-config.json)
password=$(jq -r '.database.password' /evix/secret-config.json)
database=$(jq -r '.database.database' /evix/secret-config.json)

edit () {
  id=$(jq --null-input --raw-output --argjson value "$1" '$value | .zt')
  del=$(jq --null-input --raw-output --argjson value "$1" '$value | .post.authorized == false')
  jq --null-input --compact-output --argjson value "$1" '$value | .post' |
  curl -X POST --header "$auth" -d @- "$member/$id" 2>/dev/null |
  jq --slurp --raw-output 'zt_parse_members'
  if [ "$del" == "true" ]; then
    curl -X DELETE --header "$auth" "$member/$id" >/dev/null 2>&1
  fi
}
export -f edit

{
  mysql --user "$user" --password="$password" --reconnect -B -N "$database" 2>/dev/null <<<"SELECT ip, additional_args FROM connections WHERE type='zerotier';" |
  jq --slurp --compact-output --raw-input 'split("\n") | map(split("\t") | if length > 0 then [.[0], (.[1] | split(" "))] else empty end)' &

  curl -X GET --header "$auth" "$member" 2>/dev/null;
} |
jq --slurp --compact-output 'compute_zt_diff' |
xargs -P 0 -d "\n" -I {} bash -c "edit '{}'" edit
