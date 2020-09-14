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
 * written by Mehmet Ceyran, in cooperation with:
 * CST group, Freie Universitaet Berlin
 * Website: https://github.com/rtrlib/bird-rtrlib-cli
 */

#ifndef BIRD_RTRLIB_CLI__CONFIG_H
#define	BIRD_RTRLIB_CLI__CONFIG_H

/// Specifies a type of server connection to be used.
enum connection_type {
    tcp, // Plain TCP connection
    ssh // SSH connection
};

/**
 * Application configuration structure.
 */
struct config {
    char *bird_socket_path;
    char *bird_roa_table;
    enum connection_type rtr_connection_type;
    char *rtr_host;
    char *rtr_port;
    char *rtr_bind_addr;
    char *rtr_ssh_username;
    char *rtr_ssh_hostkey_file;
    char *rtr_ssh_privkey_file;
};

/**
 * Checks the specified application configuration for errors.
 * @param
 * @return
 */
int config_check(const struct config *);

/**
 * Initializes the specified application configuration.
 * @param
 */
void config_init(struct config *);

#endif
