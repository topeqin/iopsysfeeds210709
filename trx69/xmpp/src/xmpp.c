/*
 * Copyright (C) 2020 iopsys Software Solutions AB. All rights reserved.
 *
 * Author: Amin Ben Ramdhane <amin.benramdhane@pivasoftware.com>
 *
 * This program is FREE software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the FREE Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the FREE Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */

#include <time.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <strophe.h>

#include "xmpp.h"
#include "cmd.h"
#include "log.h"
#include "xuci.h"

struct xmpp_config cur_xmpp_conf = {0};
struct xmpp_connection cur_xmpp_con = {0};

static void xmpp_connecting(void);
static void xmpp_exit(xmpp_ctx_t *ctx, xmpp_conn_t *conn);
static void xmpp_con_exit(void);

static int send_stanza_cr_response(xmpp_conn_t *const conn, xmpp_stanza_t *const stanza, void * const userdata)
{
	xmpp_stanza_t *reply = xmpp_stanza_new((xmpp_ctx_t *)userdata);
	if (!reply) {
		xmpp_syslog(SCRIT,"XMPP CR response Error");
		return -1;
	}

	xmpp_stanza_set_name(reply, "iq");
	xmpp_stanza_set_type(reply, "result");
	xmpp_stanza_set_attribute(reply, "from", xmpp_stanza_get_attribute(stanza, "to"));
	xmpp_stanza_set_attribute(reply, "id", xmpp_stanza_get_attribute(stanza, "id"));
	xmpp_stanza_set_attribute(reply, "to", xmpp_stanza_get_attribute(stanza, "from"));
	xmpp_send(conn, reply);
	xmpp_stanza_release(reply);

	return 0;
}

static int send_stanza_cr_error(xmpp_conn_t * const conn, xmpp_stanza_t * const stanza, void * const userdata, int xmpp_error)
{
	xmpp_ctx_t *ctx = (xmpp_ctx_t*)userdata;
	char *username = NULL, *password = NULL;

	xmpp_stanza_t *cr_stanza = xmpp_stanza_new(ctx);
	if (!cr_stanza) {
		xmpp_syslog(SCRIT,"XMPP CR response Error");
		return -1;
	}

	xmpp_stanza_set_name(cr_stanza, "iq");
	xmpp_stanza_set_type(cr_stanza, "error");
	xmpp_stanza_set_attribute(cr_stanza, "id", xmpp_stanza_get_attribute(stanza, "id"));
	xmpp_stanza_set_attribute(cr_stanza, "to", xmpp_stanza_get_attribute(stanza, "from"));
	xmpp_stanza_set_attribute(cr_stanza, "from", xmpp_stanza_get_attribute(stanza, "to"));

	// Connection Request Message
	xmpp_stanza_t *stanza_cr = xmpp_stanza_get_child_by_name(stanza, "connectionRequest");
	if (stanza_cr) {
		// Username
		xmpp_stanza_t *stanza_username = xmpp_stanza_get_child_by_name(stanza_cr, "username");
		if (stanza_username)
			username = xmpp_stanza_get_text(stanza_username);

		//Password
		xmpp_stanza_t *stanza_password = xmpp_stanza_get_next(stanza_username);
		if (strcmp(xmpp_stanza_get_name(stanza_password), "password") == 0)
			password = xmpp_stanza_get_text(stanza_password);
	}

	xmpp_stanza_t *stanza_cr_msg = xmpp_stanza_new(ctx);
	xmpp_stanza_set_name(stanza_cr_msg, "connectionRequest");
	xmpp_stanza_set_ns(stanza_cr_msg, XMPP_CR_NS);

	xmpp_stanza_t *stanza_username_msg = xmpp_stanza_new(ctx);
	xmpp_stanza_set_name(stanza_username_msg, "username");

	xmpp_stanza_t *username_msg = xmpp_stanza_new(ctx);
	xmpp_stanza_set_text(username_msg, username);
	xmpp_stanza_add_child(stanza_username_msg, username_msg);
	xmpp_stanza_release(username_msg);

	xmpp_stanza_add_child(stanza_cr_msg, stanza_username_msg);
	xmpp_stanza_release(stanza_username_msg);

	xmpp_stanza_t *stanza_password_msg = xmpp_stanza_new(ctx);
	xmpp_stanza_set_name(stanza_password_msg, "password");

	xmpp_stanza_t *password_msg = xmpp_stanza_new(ctx);
	xmpp_stanza_set_text(password_msg, password);
	xmpp_stanza_add_child(stanza_password_msg, password_msg);
	xmpp_stanza_release(password_msg);

	xmpp_stanza_add_child(stanza_cr_msg, stanza_password_msg);
	xmpp_stanza_release(stanza_password_msg);

	xmpp_stanza_add_child(cr_stanza, stanza_cr_msg);
	xmpp_stanza_release(stanza_cr_msg);

	xmpp_stanza_t *stanza_error = xmpp_stanza_new(ctx);
	xmpp_stanza_set_name(stanza_error, "error");
	if (xmpp_error == XMPP_SERVICE_UNAVAILABLE)
		xmpp_stanza_set_attribute(stanza_error, "code", "503");

	xmpp_stanza_set_type(stanza_error, "cancel");
	xmpp_stanza_t *stanza_service = xmpp_stanza_new(ctx);
	if (xmpp_error == XMPP_SERVICE_UNAVAILABLE)
		xmpp_stanza_set_name(stanza_service, "service-unavailable");
	else if (xmpp_error == XMPP_NOT_AUTHORIZED)
		xmpp_stanza_set_name(stanza_service, "not-autorized");

	xmpp_stanza_set_attribute(stanza_service, "xmlns", XMPP_ERROR_NS);
	xmpp_stanza_add_child(stanza_error, stanza_service);
	xmpp_stanza_release(stanza_service);

	xmpp_stanza_add_child(cr_stanza, stanza_error);
	xmpp_stanza_release(stanza_error);

	xmpp_send(conn, cr_stanza);
	xmpp_stanza_release(cr_stanza);

	// Free allocated memory
	FREE(username);
	FREE(password);

	return 0;
}

static bool check_xmpp_jid_authorized(const char *from)
{
	// XMPP config : allowed jabber id is empty
	if (cur_xmpp_conf.xmpp_allowed_jid == NULL || cur_xmpp_conf.xmpp_allowed_jid[0] == '\0') {
		xmpp_syslog(SDEBUG,"xmpp connection request handler : allowed jid is empty");
		return true;
	}

	// XMPP config : allowed jabber id is not empty
	char *spch = NULL;

	xmpp_syslog(SDEBUG,"xmpp connection request handler : check each jabber id");
	char *allowed_jid = strdup(cur_xmpp_conf.xmpp_allowed_jid);
	char *pch = strtok_r(allowed_jid, ",", &spch);
	while (pch != NULL) {
		if (strncmp(pch, from, strlen(pch)) == 0) {
			FREE(allowed_jid);
			xmpp_syslog(SDEBUG,"xmpp connection request handler : jabber id is authorized");
			return true;
		}
		pch = strtok_r(NULL, ",", &spch);
	}
	FREE(allowed_jid);

	xmpp_syslog(SDEBUG,"xmpp connection request handler : jabber id is not authorized");
	return false;
}

static int cr_handler(xmpp_conn_t * const conn, xmpp_stanza_t * const stanza, void * const userdata)
{
	bool valid_ns = true, auth_status = false, service_available = false;

	if (xmpp_stanza_get_child_by_name(stanza, "connectionRequest")) {
		const char *from = (char *)xmpp_stanza_get_attribute(stanza, "from");

		if (!check_xmpp_jid_authorized(from)) {
			service_available = false;
			xmpp_syslog(SDEBUG,"xmpp connection request handler not authorized by allowed jid");
			goto xmpp_end;
		}
	} else {
		xmpp_syslog(SDEBUG,"xmpp connection request handler does not contain an iq type");
		return 1;
	}

	xmpp_stanza_t *stanza_cr = xmpp_stanza_get_child_by_name(stanza, "connectionRequest");
	if (stanza_cr) {
		service_available = true;
		char *name_space = (char *)xmpp_stanza_get_attribute(stanza_cr, "xmlns");
		if (strcmp(name_space, XMPP_CR_NS) != 0) {
			valid_ns = false;
			goto xmpp_end; //send error response
		}

		xmpp_stanza_t *mech = xmpp_stanza_get_child_by_name(stanza_cr, "username");
		if (mech) {
			char *text = xmpp_stanza_get_text(mech);
			xmpp_uci_init();
			const char *username = xmpp_uci_get_value("cwmp", "cpe", "userid");
			if (strcmp(text, username) == 0) {
				FREE(text);
				mech = xmpp_stanza_get_next(mech);
				if (strcmp(xmpp_stanza_get_name(mech), "password") == 0) {
					text = xmpp_stanza_get_text(mech);
					const char *password = xmpp_uci_get_value("cwmp", "cpe", "passwd");
					auth_status = (strcmp(text, password) == 0) ? true : false;
				}
			}
			xmpp_uci_fini();
			FREE(text);
		}
	} else {
		service_available = false;
		goto xmpp_end; //send error response
	}

xmpp_end:
	if (!valid_ns) {

		xmpp_syslog(SINFO, "XMPP Invalid Name space");
		send_stanza_cr_error(conn, stanza, userdata, XMPP_SERVICE_UNAVAILABLE);

	} else if (!service_available) {

		xmpp_syslog(SINFO, "XMPP Service Unavailable");
		send_stanza_cr_error(conn, stanza, userdata, XMPP_SERVICE_UNAVAILABLE);

	} else if (!auth_status) {

		xmpp_syslog(SINFO, "XMPP Not Authorized");
		send_stanza_cr_error(conn, stanza, userdata, XMPP_NOT_AUTHORIZED);

	} else {

		xmpp_syslog(SINFO, "XMPP Authorized");
		send_stanza_cr_response(conn, stanza, userdata);
		XMPP_CMD(7, "ubus", "-t", "3", "call", "tr069", "inform", "{\"event\" : \"6 connection request\"}");

	}

	return 1;
}

static int ping_keepalive_handler(xmpp_conn_t * const conn, void * const userdata)
{
	xmpp_stanza_t *ping_ka, *ping;
	xmpp_ctx_t *ctx = (xmpp_ctx_t*)userdata;
	char jid[512] = {0};

	xmpp_syslog(SDEBUG, "XMPP PING OF KEEPALIVE ");

	snprintf(jid, sizeof(jid), "%s@%s/%s", cur_xmpp_con.username, cur_xmpp_con.domain, cur_xmpp_con.resource);

	ping_ka = xmpp_stanza_new(ctx);
	xmpp_stanza_set_name(ping_ka, "iq");
	xmpp_stanza_set_type(ping_ka, "get");
	xmpp_stanza_set_id(ping_ka, "s2c1");
	xmpp_stanza_set_attribute(ping_ka, "from", jid);
	xmpp_stanza_set_attribute(ping_ka, "to", cur_xmpp_con.domain);

	ping = xmpp_stanza_new(ctx);
	xmpp_stanza_set_name(ping, "ping");
	xmpp_stanza_set_attribute(ping, "xmlns", "urn:xmpp:ping");
	xmpp_stanza_add_child(ping_ka, ping);
	xmpp_stanza_release(ping);
	xmpp_send(conn, ping_ka);
	xmpp_stanza_release(ping_ka);

	return 1;
}

static void conn_handler(xmpp_conn_t * const conn, const xmpp_conn_event_t status,
		const int error, xmpp_stream_error_t * const stream_error,
		void * const userdata)
{
	xmpp_ctx_t *ctx = (xmpp_ctx_t *)userdata;
	static int attempt = 0;

	if (status == XMPP_CONN_CONNECT) {
		xmpp_syslog(SINFO,"XMPP Connection Established");
		attempt = 0;

		xmpp_handler_add(conn, cr_handler, NULL, "iq", NULL, ctx);
		xmpp_timed_handler_add(conn, ping_keepalive_handler, cur_xmpp_con.keepalive_interval * 1000, userdata);

		xmpp_stanza_t *pres = xmpp_stanza_new(ctx);
		xmpp_stanza_set_name(pres, "presence");
		xmpp_send(conn, pres);
		xmpp_stanza_release(pres);

		xmpp_conn_set_keepalive(conn, 30, cur_xmpp_con.keepalive_interval);
	} else {
		xmpp_syslog(SINFO,"XMPP Connection Lost");
		xmpp_exit(ctx, conn);

		xmpp_syslog(SINFO,"XMPP Connection Retry");
		srand(time(NULL));

		if (attempt == 0 && cur_xmpp_con.connect_attempt != 0) {

			if (cur_xmpp_con.retry_initial_interval != 0)
				sleep(rand()%cur_xmpp_con.retry_initial_interval);

		} else if(attempt > cur_xmpp_con.connect_attempt) {

			xmpp_syslog(SINFO,"XMPP Connection Aborted");
			xmpp_exit(ctx, conn);
			xmpp_con_exit();
			exit(EXIT_FAILURE);

		} else if( attempt >= 1 && cur_xmpp_con.connect_attempt != 0 ) {

			int delay = cur_xmpp_con.retry_initial_interval * (cur_xmpp_con.retry_interval_multiplier/1000) * (attempt -1);
			if (delay > cur_xmpp_con.retry_max_interval)
				sleep(cur_xmpp_con.retry_max_interval);
			else
				sleep(delay);

		} else
			sleep(DEFAULT_XMPP_RECONNECTION_RETRY);

		attempt += 1;
		xmpp_connecting();
	}
}

static void xmpp_connecting(void)
{
	xmpp_log_t log_xmpp;
	char jid[512] = {0};
	static int attempt = 0;
	int connected = 0;
	long flags = 0;

	xmpp_initialize();
	int xmpp_mesode_log_level = xmpp_log_get_level(cur_xmpp_conf.xmpp_loglevel);
	log_xmpp.handler = &xmpp_syslog_handler;
	log_xmpp.userdata = &(xmpp_mesode_log_level);
	xmpp_ctx_t *ctx = xmpp_ctx_new(NULL, &log_xmpp);
	xmpp_conn_t *conn = xmpp_conn_new(ctx);

	if(cur_xmpp_con.usetls)
		flags |= XMPP_CONN_FLAG_MANDATORY_TLS; /* Set flag XMPP_CONN_FLAG_MANDATORY_TLS to oblige the verification of tls */
	else
		flags |= XMPP_CONN_FLAG_TRUST_TLS; /* Set flag XMPP_CONN_FLAG_TRUST_TLS to ignore result of the verification */
	xmpp_conn_set_flags(conn, flags);

	snprintf(jid, sizeof(jid), "%s@%s/%s", cur_xmpp_con.username, cur_xmpp_con.domain, cur_xmpp_con.resource);

	xmpp_conn_set_jid(conn, jid);
	xmpp_conn_set_pass(conn, cur_xmpp_con.password);

	/* initiate connection */
	if( strcmp(cur_xmpp_con.serveralgorithm,"DNS-SRV") == 0)
		connected = xmpp_connect_client(conn, NULL, 0, conn_handler, ctx);
	else
		connected = xmpp_connect_client(conn, cur_xmpp_con.serveraddress[0] ? cur_xmpp_con.serveraddress : NULL,
										cur_xmpp_con.port, conn_handler, ctx);

	if (connected < 0 ) {
		xmpp_exit(ctx, conn);
		xmpp_syslog(SINFO,"XMPP Connection Retry");
		srand(time(NULL));
		if (attempt == 0 && cur_xmpp_con.connect_attempt != 0) {
			if (cur_xmpp_con.retry_initial_interval != 0)
				sleep(rand()%cur_xmpp_con.retry_initial_interval);
		} else if (attempt > cur_xmpp_con.connect_attempt) {
			xmpp_syslog(SINFO,"XMPP Connection Aborted");
			xmpp_exit(ctx, conn);
			xmpp_con_exit();
			exit(EXIT_FAILURE);
		} else if (attempt >= 1 && cur_xmpp_con.connect_attempt != 0) {
			int delay = cur_xmpp_con.retry_initial_interval * (cur_xmpp_con.retry_interval_multiplier/1000) * (attempt -1);
			if (delay > cur_xmpp_con.retry_max_interval)
				sleep(cur_xmpp_con.retry_max_interval);
			else
				sleep(delay);
		} else
			sleep(DEFAULT_XMPP_RECONNECTION_RETRY);
		attempt += 1;
		xmpp_connecting();
	} else {
		attempt = 0;
		xmpp_syslog(SDEBUG,"XMPP Handle Connection");
		xmpp_run(ctx);
	}
}

static void xmpp_exit(xmpp_ctx_t *ctx, xmpp_conn_t *conn)
{
	xmpp_stop(ctx);
	xmpp_conn_release(conn);
	xmpp_ctx_free(ctx);
	xmpp_shutdown();
}

static void xmpp_con_exit(void)
{
	FREE(cur_xmpp_con.username);
	FREE(cur_xmpp_con.password);
	FREE(cur_xmpp_con.domain);
	FREE(cur_xmpp_con.resource);
	FREE(cur_xmpp_con.serveraddress);
	FREE(cur_xmpp_con.serveralgorithm);
	FREE(cur_xmpp_conf.xmpp_allowed_jid);
}

static void xmpp_global_conf(void)
{
	xmpp_uci_init();

	// XMPP Log Level
	const char *loglevel = xmpp_uci_get_value("xmpp", "xmpp", "loglevel");
	if (loglevel != NULL && *loglevel != '\0')
		cur_xmpp_conf.xmpp_loglevel = atoi(loglevel);
	else
		cur_xmpp_conf.xmpp_loglevel = DEFAULT_LOGLEVEL;
	xmpp_syslog(SDEBUG,"Log Level of XMPP connection is :%d", cur_xmpp_conf.xmpp_loglevel);

	// XMPP Allowed Jabber id
	const char *allowed_jid = xmpp_uci_get_value("xmpp", "xmpp", "allowed_jid");
	if (allowed_jid != NULL && *allowed_jid != '\0') {
		cur_xmpp_conf.xmpp_allowed_jid = strdup(allowed_jid);
		xmpp_syslog(SDEBUG,"XMPP connection allowed jaber id :%s", cur_xmpp_conf.xmpp_allowed_jid);
	} else {
		cur_xmpp_conf.xmpp_allowed_jid = strdup("");
		xmpp_syslog(SDEBUG,"XMPP connection allowed jaber id is empty");
	}

	xmpp_uci_fini();
}

static const char *get_connection_config(const char *option, const char *identifier)
{
	struct uci_section *s;

	xmpp_uci_foreach_section("xmpp", "connection", s) {
		const char *xmpp_id = xmpp_uci_get_value_bysection(s, "xmpp_id");
		if (strcmp(xmpp_id, identifier) == 0)
			return xmpp_uci_get_value_bysection(s, option);
	}
	return "";
}

static const char *get_connection_server_config(const char *option, const char *identifier)
{
	struct uci_section *s;

	xmpp_uci_foreach_section("xmpp", "connection_server", s) {
		const char *con_id = xmpp_uci_get_value_bysection(s, "con_id");
		if (strcmp(con_id, identifier) == 0)
			return xmpp_uci_get_value_bysection(s, option);
	}
	return "";
}

static void xmpp_con_init(void)
{
	xmpp_uci_init();

	const char *identifier = xmpp_uci_get_value("xmpp", "xmpp", "id");

	cur_xmpp_con.username = strdup(get_connection_config("username", identifier));
	cur_xmpp_con.password = strdup(get_connection_config("password", identifier));
	cur_xmpp_con.domain = strdup(get_connection_config("domain", identifier));
	cur_xmpp_con.resource = strdup(get_connection_config("resource", identifier));
	cur_xmpp_con.usetls = atoi(get_connection_config("usetls", identifier));
	cur_xmpp_con.serveralgorithm = strdup(get_connection_config("serveralgorithm", identifier));
	cur_xmpp_con.serveraddress = strdup(get_connection_server_config("server_address", identifier));
	cur_xmpp_con.port = atoi(get_connection_server_config("port", identifier));
	cur_xmpp_con.keepalive_interval = atoi(get_connection_config("interval", identifier));

	cur_xmpp_con.connect_attempt = atoi(get_connection_config("attempt", identifier));
	if (cur_xmpp_con.connect_attempt) {
		cur_xmpp_con.retry_initial_interval = atoi(get_connection_config("initial_retry_interval", identifier));
		cur_xmpp_con.retry_initial_interval = (cur_xmpp_con.retry_initial_interval) ? cur_xmpp_con.retry_initial_interval : DEFAULT_RETRY_INITIAL_INTERVAL;
		cur_xmpp_con.retry_interval_multiplier = atoi(get_connection_config("retry_interval_multiplier", identifier));
		cur_xmpp_con.retry_interval_multiplier = (cur_xmpp_con.retry_interval_multiplier) ? cur_xmpp_con.retry_interval_multiplier : DEFAULT_RETRY_INTERVAL_MULTIPLIER;
		cur_xmpp_con.retry_max_interval = atoi(get_connection_config("retry_max_interval", identifier));
		cur_xmpp_con.retry_max_interval = (cur_xmpp_con.retry_max_interval) ? cur_xmpp_con.retry_max_interval : DEFAULT_RETRY_MAX_INTERVAL;
	}

	xmpp_syslog(SDEBUG,"XMPP Connection id: %s", identifier);
	xmpp_syslog(SDEBUG,"XMPP username: %s", cur_xmpp_con.username);
	xmpp_syslog(SDEBUG,"XMPP password: %s", cur_xmpp_con.password);
	xmpp_syslog(SDEBUG,"XMPP domain: %s", cur_xmpp_con.domain);
	xmpp_syslog(SDEBUG,"XMPP resource: %s", cur_xmpp_con.resource);
	xmpp_syslog(SDEBUG,"XMPP use_tls: %d", cur_xmpp_con.usetls);
	xmpp_syslog(SDEBUG,"XMPP serveralgorithm: %s", cur_xmpp_con.serveralgorithm);
	xmpp_syslog(SDEBUG,"XMPP server_address: %s", cur_xmpp_con.serveraddress);
	xmpp_syslog(SDEBUG,"XMPP port: %d", cur_xmpp_con.port);
	xmpp_syslog(SDEBUG,"XMPP keepalive_interval: %d", cur_xmpp_con.keepalive_interval);
	xmpp_syslog(SDEBUG,"XMPP connect_attempt: %d", cur_xmpp_con.connect_attempt);
	xmpp_syslog(SDEBUG,"XMPP retry_initial_interval: %d", cur_xmpp_con.retry_initial_interval);
	xmpp_syslog(SDEBUG,"XMPP retry_interval_multiplier: %d", cur_xmpp_con.retry_interval_multiplier);
	xmpp_syslog(SDEBUG,"XMPP retry_max_interval: %d", cur_xmpp_con.retry_max_interval);

	xmpp_uci_fini();
}

int main(void)
{
	xmpp_global_conf();
	xmpp_syslog(SINFO,"START XMPP");

	xmpp_con_init();
	xmpp_connecting();

	xmpp_syslog(SINFO,"EXIT XMPP");
	xmpp_con_exit();

	return 0;
}
