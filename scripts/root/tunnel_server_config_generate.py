#! /usr/bin/env python3
# NOTE(bryce): Written by Bryce Wilson on 2020-09-13, migrated from tunnel_server_config_generate.sh (prior known as
#  gen-config
#  * 2020-09-14|>Bryce|>Migrated from old file
#  * 2020-12-15|>Bryce|>Renamed from gen-config.py to tunnel_server_config_generate.py

import mysql.connector

database = None

try:
	database = mysql.connector.connect(user='evix', password='***REMOVED***', host='127.0.0.1', database='evix', autocommit=True)
except mysql.connector.Error as err:
	print("Something went wrong with the database connection:")
	print(err)
	exit(1)

cursor = database.cursor(buffered=True)

config = {}
cursor.execute("SELECT server,type,tunnel_id,ip,additional_args,client_id FROM connections")

for i in cursor:
	server, type, id, ip, additional_args, client_id = i
	if type == "zerotier":
		config[f"zerotier.peers"] = config.get(f"zerotier.peers", "") + f"{ip} {additional_args}\n"
	elif type == "openvpn":
		config[f"openvpn.peers"] = config.get(f"openvpn.peers", "") + f"{ip} {client_id} {additional_args}\n"
	else:
		config[f"{server}.{type}"] = config.get(f"{server}.{type}", "") + f"{id} {ip} {additional_args}\n"

for i in config:
	with open(f"/evix/config/peers/{i}", "w") as file:
		print(f"New config in /evix/config/peers/{i}:\n{config[i]}\n")
		file.write(config[i])
