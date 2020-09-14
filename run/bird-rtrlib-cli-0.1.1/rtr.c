/*
 * This file is part of BIRD-RTRlib-CLI.
 *
 * BIRD-RTRlib-CLI is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.
 *
 * BIRD-RTRlib-CLI is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
 * License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BIRD-RTRlib-CLI; see the file COPYING.
 *
 * written by smlng, Mehmet Ceyran, in cooperation with:
 * CST group, Freie Universitaet Berlin
 * Website: https://github.com/rtrlib/bird-rtrlib-cli
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "rtr.h"

struct tr_ssh_config *rtr_create_ssh_config(const char *host,
                                            const char *port,
                                            const char *bindaddr,
                                            const char *server_hostkey_path,
                                            const char *username,
                                            const char *client_privkey_path)
{
    // Initialize result.
    struct tr_ssh_config *result = malloc(sizeof (struct tr_ssh_config));
    memset(result, 0, sizeof (struct tr_ssh_config));
    // Assign host, port and username (mandatory).
    if (host)
        result->host = strdup(host);
    if (port) {
        unsigned int iport = atoi(port);
        result->port = iport;
    }
    if (username)
        result->username = strdup(username);
    // Assign bind address if available.
    if (bindaddr)
        result->bindaddr = strdup(bindaddr);
    // Assign key paths (optional).
    if (server_hostkey_path)
        result->server_hostkey_path = strdup(server_hostkey_path);
    if (client_privkey_path)
        result->client_privkey_path = strdup(client_privkey_path);
    // Return result.
    return result;
}

struct tr_tcp_config *rtr_create_tcp_config(const char *host,
                                            const char *port,
                                            const char *bindaddr)
{
    // Initialize result.
    struct tr_tcp_config *result = malloc(sizeof(struct tr_tcp_config));
    memset(result, 0, sizeof(struct tr_tcp_config));
    // Populate result.
    if(host)
        result->host = strdup(host);
    if (port)
        result->port = strdup(port);
    if (bindaddr)
        result->bindaddr = strdup(bindaddr);
    // Return result.
    return result;
}
