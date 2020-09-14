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

#ifndef BIRD_RTRLIB_CLI__RTR_H
#define	BIRD_RTRLIB_CLI__RTR_H

#include <rtrlib/rtrlib.h>

/**
 * Creates and returns a new `tr_ssh_config` structure for an SSH connection to
 * the specified specified host and port, authenticated by the optional hostkey
 * path, with the specified user authenticated by the key pair.
 * @param host
 * @param port
 * @param server_hostkey_path
 * @param username
 * @param client_privkey_path
 * @return
 */
struct tr_ssh_config *rtr_create_ssh_config(const char *host,
                                            const char *port,
                                            const char *bindaddr,
                                            const char *server_hostkey_path,
                                            const char *username,
                                            const char *client_privkey_path);

/**
 * Creates and returns a new `tr_tcp_config` structure from the specified host
 * and port.
 * @param host
 * @param port
 * @return
 */
struct tr_tcp_config *rtr_create_tcp_config(const char *host,
                                            const char *port,
                                            const char *bindaddr);

#endif
