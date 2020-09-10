/*
 * Copyright (C) 2020 iopsys Software Solutions AB. All rights reserved.
 *
 * Author: Amin Ben Ramdhane <amin.benramdhane@pivasoftware.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */

#ifndef _XMPPUCI_H_
#define _XMPPUCI_H_

#include <uci.h>

void xmpp_uci_init(void);
void xmpp_uci_fini(void);

struct uci_section *xmpp_uci_walk_section(const char *package, const char *section_type, struct uci_section *prev_section);
const char *xmpp_uci_get_value_bysection(struct uci_section *section, const char *option);
const char *xmpp_uci_get_value(const char *package, const char *section, const char *option);

#define xmpp_uci_foreach_section(package, section_type, section) \
	for (section = xmpp_uci_walk_section(package, section_type, NULL); \
		section != NULL; \
		section = xmpp_uci_walk_section(package, section_type, section))

#endif /* _XMPPUCI_H_ */
