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

#include <argp.h>
#include <stddef.h>
#include <string.h>

#include "config.h"

#define ARGKEY_BIRD_ROA_TABLE 't'
#define ARGKEY_BIRD_SOCKET 'b'
#define ARGKEY_RTR_ADDRESS 'r'
#define ARGKEY_RTR_SOURCE_ADDRESS 0x100
#define ARGKEY_RTRSSH_ENABLE 's'
#define ARGKEY_RTRSSH_HOSTKEY 0x101
#define ARGKEY_RTRSSH_PRIVKEY 0x102
#define ARGKEY_RTRSSH_USERNAME 0x103

// Parser function for argp_parse().
static error_t argp_parser(int key, char *arg, struct argp_state *state)
{
    // Shortcut to config object passed to argp_parse().
    struct config *config = state->input;
    // Process command line argument.
    switch (key) {
        case ARGKEY_BIRD_ROA_TABLE:
            config->bird_roa_table = arg;
            break;
        case ARGKEY_BIRD_SOCKET:
            // Process BIRD socket path.
            config->bird_socket_path = arg;
            break;
        case ARGKEY_RTR_ADDRESS:
            config->rtr_host = strtok(arg, ":");
            config->rtr_port = strtok(0, ":");
            break;
        case ARGKEY_RTR_SOURCE_ADDRESS:
            config->rtr_bind_addr = arg;
            break;
        case ARGKEY_RTRSSH_ENABLE:
            config->rtr_connection_type = ssh;
            break;
        case ARGKEY_RTRSSH_HOSTKEY:
            config->rtr_ssh_hostkey_file = arg;
            break;
        case ARGKEY_RTRSSH_PRIVKEY:
            config->rtr_ssh_privkey_file = arg;
            break;
        case ARGKEY_RTRSSH_USERNAME:
            config->rtr_ssh_username = arg;
            break;
        default:
            // Process unknown argument.
            return ARGP_ERR_UNKNOWN;
    }
    // Return success.
    return 0;
}

// Parses the specified command line arguments into the program config.
int parse_cli(int argc, char **argv, struct config *config)
{
    // Command line options definition.
    const struct argp_option argp_options[] = {
        {
            "bird-socket",
            ARGKEY_BIRD_SOCKET,
            "<BIRD_SOCKET_PATH>",
            0,
            "Path to the BIRD control socket.",
            0
        },
        {
            "bird-roa-table",
            ARGKEY_BIRD_ROA_TABLE,
            "<BIRD_ROA_TABLE>",
            0,
            "(optional) Name of the BIRD ROA table for RPKI ROA imports.",
            0
        },
        {
            "rtr-address",
            ARGKEY_RTR_ADDRESS,
            "<RTR_HOST>:<RTR_PORT>",
            0,
            "Address of the RTR server.",
            1
        },
        {
            "rtr-source-address",
            ARGKEY_RTR_SOURCE_ADDRESS,
            "<RTR_SOURCE_ADDRESS>",
            0,
            "(optional) Source address of the connection to the RTR server.",
            1
        },
        {
            "ssh",
            ARGKEY_RTRSSH_ENABLE,
            0,
            0,
            "Use an SSH connection instead of plain TCP.",
            1
        },
        {
            "rtr-ssh-hostkey",
            ARGKEY_RTRSSH_HOSTKEY,
            "<RTR_SSH_HOSTKEY_FILE>",
            0,
            "(optional) Path to a file containing the SSH host key of the RTR "
            "server. Uses the default known_hosts file if not specified.",
            2
        },
        {
            "rtr-ssh-username",
            ARGKEY_RTRSSH_USERNAME,
            "<RTR_SSH_USERNAME>",
            0,
            "Name of the user to be authenticated with the RTR server. "
            "Mandatory for SSH connections.",
            2
        },
        {
            "rtr-ssh-privkey",
            ARGKEY_RTRSSH_PRIVKEY,
            "<RTR_SSH_PRIVKEY_FILE>",
            0,
            "(optional) Path to a file containing the private key of the user "
            "to be authenticated with the RTR server if an SSH connection is "
            "used. Uses the user's default identity file if not specified.",
            2
        },
        {0}
    };
    // argp structure to be passed to argp_parse().
    const struct argp argp = {
        argp_options,
        &argp_parser,
        NULL,
        "RTRLIB <-> BIRD interface",
        NULL,
        NULL,
        NULL
    };
    // Parse command line. Exits on errors.
    argp_parse(&argp, argc, argv, 0, NULL, config);
    // Return success.
    return 1;
}
