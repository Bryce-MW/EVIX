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
 * written by smlng, and Mehmet Ceyran, in cooperation with:
 * CST group, Freie Universitaet Berlin
 * Website: https://github.com/rtrlib/bird-rtrlib-cli
 */

#ifndef BIRD_RTRLIB_CLI__BIRD_H
#define	BIRD_RTRLIB_CLI__BIRD_H

#include <string.h>
#include <syslog.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>

/**
 * Connects to the BIRD daemon listening at the specified socket. Returns the
 * socket on success or -1 on failure.
 * @param socket_path
 * @return
 */
int bird_connect(const char *socket_path);

#endif // BIRD_RTRLIB_CLI__BIRD_H
