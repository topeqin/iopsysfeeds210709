/*
 * Copyright (C) 2020 iopsys Software Solutions AB
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation
 *
 *	Author: Amin Ben Ramdhane <amin.benramdhane@pivasoftware.com>
 */

#include <libbbf_api/dmbbf.h>
#include <libbbf_api/dmcommon.h>
#include <libbbf_api/dmuci.h>
#include <libbbf_api/dmubus.h>
#include <libbbf_api/dmjson.h>

#include "datamodel.h"

/* ********** RootDynamicObj ********** */
LIB_MAP_OBJ tRootDynamicObj[] = {
/* parentobj, nextobject */
{"Device.", tDeviceXMPPObj},
{0}
};

static int add_xmpp_connection(char *refparam, struct dmctx *ctx, void *data, char **instance)
{
	struct uci_section *xmpp_con = NULL, *xmpp_con_srv = NULL, *dmmap_xmpp = NULL;
	char id[16];

	char *last_inst = get_last_instance_bbfdm("dmmap_xmpp", "connection", "con_inst");
	snprintf(id, sizeof(id), "%d", (last_inst) ? atoi(last_inst) + 1 : 1);

	dmuci_add_section("xmpp", "connection", &xmpp_con);
	dmuci_set_value_by_section(xmpp_con, "xmpp_id", id);
	dmuci_set_value_by_section(xmpp_con, "enable", "0");
	dmuci_set_value_by_section(xmpp_con, "interval", "30");
	dmuci_set_value_by_section(xmpp_con, "attempt", "16");
	dmuci_set_value_by_section(xmpp_con, "serveralgorithm", "DNS-SRV");

	dmuci_add_section("xmpp", "connection_server", &xmpp_con_srv);
	dmuci_set_value_by_section(xmpp_con_srv, "con_id", id);
	dmuci_set_value_by_section(xmpp_con_srv, "enable", "0");
	dmuci_set_value_by_section(xmpp_con_srv, "port", "5222");

	dmuci_add_section_bbfdm("dmmap_xmpp", "connection_server", &dmmap_xmpp);
	dmuci_set_value_by_section(dmmap_xmpp, "section_name", section_name(xmpp_con_srv));
	dmuci_set_value_by_section(dmmap_xmpp, "con_srv_inst", "1");

	dmuci_add_section_bbfdm("dmmap_xmpp", "connection", &dmmap_xmpp);
	dmuci_set_value_by_section(dmmap_xmpp, "section_name", section_name(xmpp_con));
	*instance = update_instance(last_inst, 2, dmmap_xmpp, "con_inst");
	return 0;
}

static int delete_xmpp_connection(char *refparam, struct dmctx *ctx, void *data, char *instance, unsigned char del_action)
{
	struct uci_section *s = NULL, *ss = NULL, *dmmap_section = NULL, *stmp = NULL;
	char *prev_con_id;
	int found = 0;
	
	switch (del_action) {
		case DEL_INST:
			dmuci_get_value_by_section_string((struct uci_section *)data, "xmpp_id", &prev_con_id);
			uci_foreach_option_eq_safe("xmpp", "connection_server", "con_id", prev_con_id, stmp, s) {
				get_dmmap_section_of_config_section("dmmap_xmpp", "connection_server", section_name(s), &dmmap_section);
				dmuci_delete_by_section(dmmap_section, NULL, NULL);
				dmuci_delete_by_section(s, NULL, NULL);
				break;
			}

			get_dmmap_section_of_config_section("dmmap_xmpp", "connection", section_name((struct uci_section *)data), &dmmap_section);
			dmuci_delete_by_section(dmmap_section, NULL, NULL);
			dmuci_delete_by_section((struct uci_section *)data, NULL, NULL);
			return 0;
		case DEL_ALL:
			uci_foreach_sections("xmpp", "connection", s) {
				if (found != 0) {
					get_dmmap_section_of_config_section("dmmap_xmpp", "connection", section_name(ss), &dmmap_section);
					dmuci_delete_by_section(dmmap_section, NULL, NULL);
					dmuci_delete_by_section(ss, NULL, NULL);
				}
				ss = s;
				found++;
			}
			if (ss != NULL) {
				get_dmmap_section_of_config_section("dmmap_xmpp", "connection", section_name(ss), &dmmap_section);
				dmuci_delete_by_section(dmmap_section, NULL, NULL);
				dmuci_delete_by_section(ss, NULL, NULL);
			}

			found = 0;
			uci_foreach_sections("xmpp", "connection_server", s) {
				if (found != 0) {
					get_dmmap_section_of_config_section("dmmap_xmpp", "connection_server", section_name(ss), &dmmap_section);
					dmuci_delete_by_section(dmmap_section, NULL, NULL);
					dmuci_delete_by_section(ss, NULL, NULL);
				}
				ss = s;
				found++;
			}
			if (ss != NULL) {
				get_dmmap_section_of_config_section("dmmap_xmpp", "connection_server", section_name(ss), &dmmap_section);
				dmuci_delete_by_section(dmmap_section, NULL, NULL);
				dmuci_delete_by_section(ss, NULL, NULL);
			}

			return 0;
	}
	return 0;
}

/*#Device.XMPP.ConnectionNumberOfEntries!UCI:xmpp/xmpp_connection/*/
static int get_xmpp_connection_nbr_entry(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	struct uci_section *s;
	int cnt = 0;

	uci_foreach_sections("xmpp", "connection", s) {
		cnt++;
	}
	dmasprintf(value, "%d", cnt); // MEM WILL BE FREED IN DMMEMCLEAN
	return 0;
}

static int get_xmpp_connection_supported_server_connect_algorithms(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "DNS-SRV,ServerTable";
	return 0;
}

/*#Device.XMPP.Connection.{i}.Enable!UCI:xmpp/xmpp_connection,@i-1/enable*/
static int get_connection_enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "enable", "1");
	return 0;
}

static int set_connection_enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	bool b;

	switch (action) {
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			return 0;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "enable", b ? "1" : "0");
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Alias!UCI:dmmap_xmpp/connection,@i-1/con_alias*/
static int get_xmpp_connection_alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	struct uci_section *dmmap_section = NULL;

	get_dmmap_section_of_config_section("dmmap_xmpp", "connection", section_name((struct uci_section *)data), &dmmap_section);
	dmuci_get_value_by_section_string(dmmap_section, "con_alias", value);
	if ((*value)[0] == '\0')
		dmasprintf(value, "cpe-%s", instance);
	return 0;
}

static int set_xmpp_connection_alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	struct uci_section *dmmap_section = NULL;

	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			get_dmmap_section_of_config_section("dmmap_xmpp", "connection", section_name((struct uci_section *)data), &dmmap_section);
			dmuci_set_value_by_section(dmmap_section, "con_alias", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Username!UCI:xmpp/xmpp_connection,@i-1/username*/
static int get_xmpp_connection_username(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "username", value);
	return 0;
}

static int set_xmpp_connection_username(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "username", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Password!UCI:xmpp/xmpp_connection,@i-1/password*/
static int get_xmpp_connection_password(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "";
	return 0;
}

static int set_xmpp_connection_password(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "password", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Domain!UCI:xmpp/xmpp_connection,@i-1/domain*/
static int get_xmpp_connection_domain(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "domain", value);
	return 0;
}

static int set_xmpp_connection_domain(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "domain", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Resource!UCI:xmpp/xmpp_connection,@i-1/resource*/
static int get_xmpp_connection_resource(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "resource", value);
	return 0;
}

static int set_xmpp_connection_resource(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "resource", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.ServerConnectAlgorithm!UCI:xmpp/xmpp_connection,@i-1/serveralgorithm*/
static int get_xmpp_connection_server_connect_algorithm(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "serveralgorithm", value);
	return 0;
}

static int set_xmpp_connection_server_connect_algorithm(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, ServerConnectAlgorithm, 4, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "serveralgorithm", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.KeepAliveInterval!UCI:xmpp/xmpp_connection,@i-1/interval*/
static int get_xmpp_connection_keepalive_interval(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "interval", "-1");
	return 0;
}

static int set_xmpp_connection_keepalive_interval(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_long(value, RANGE_ARGS{{"-1",NULL}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "interval", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.ServerConnectAttempts!UCI:xmpp/xmpp_connection,@i-1/attempt*/
static int get_xmpp_connection_server_attempts(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "attempt", "16");
	return 0;
}

static int set_xmpp_connection_server_attempts(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{NULL,NULL}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "attempt", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.ServerRetryInitialInterval!UCI:xmpp/xmpp_connection,@i-1/initial_retry_interval*/
static int get_xmpp_connection_retry_initial_interval(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "initial_retry_interval", "60");
	return 0;
}

static int set_xmpp_connection_retry_initial_interval(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1","65535"}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "initial_retry_interval", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.ServerRetryIntervalMultiplier!UCI:xmpp/xmpp_connection,@i-1/retry_interval_multiplier*/
static int get_xmpp_connection_retry_interval_multiplier(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "retry_interval_multiplier", "2000");
	return 0;
}

static int set_xmpp_connection_retry_interval_multiplier(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1000","65535"}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "retry_interval_multiplier", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.ServerRetryMaxInterval!UCI:xmpp/xmpp_connection,@i-1/retry_max_interval*/
static int get_xmpp_connection_retry_max_interval(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "retry_max_interval", "30720");
	return 0;
}

static int set_xmpp_connection_retry_max_interval(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1",NULL}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "retry_max_interval", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.UseTLS!UCI:xmpp/xmpp_connection,@i-1/usetls*/
static int get_xmpp_connection_server_usetls(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "usetls", "1");
	return 0;
}

static int set_xmpp_connection_server_usetls(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action) 
{
	bool b;

	switch (action) {
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			return 0;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "usetls", b ? "1" : "0");
			return 0;
	}
	return 0;
}

static int get_xmpp_connection_jabber_id(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	char *resource, *domain, *username;

	dmuci_get_value_by_section_string((struct uci_section *)data, "resource", &resource);
	dmuci_get_value_by_section_string((struct uci_section *)data, "domain", &domain);
	dmuci_get_value_by_section_string((struct uci_section *)data, "username", &username);
	if (*resource != '\0' || *domain != '\0' || *username != '\0')
		dmasprintf(value, "%s@%s/%s", username, domain, resource);
	else
		*value = "";
	return 0;
}

/*#Device.XMPP.Connection.{i}.Status!UCI:xmpp/xmpp_connection,@i-1/enable*/
static int get_xmpp_connection_status(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	char *status;

	dmuci_get_value_by_section_string((struct uci_section *)data, "enable", &status);
	*value = (strcmp(status, "1") == 0) ? "Enabled" : "Disabled";
	return 0;
}

static int get_xmpp_connection_server_number_of_entries(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "1";
	return 0;
}

/*#Device.XMPP.Connection.{i}.Server.{i}.Enable!UCI:xmpp/xmpp_connection,@i-1/enable*/
static int get_xmpp_connection_server_enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "enable", "1");
	return 0;
}

static int set_xmpp_connection_server_enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action) {
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			return 0;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "enable", b ? "1" : "0");
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Server.{i}.Alias!UCI:dmmap_xmpp/connection_server,@i-1/con_srv_alias*/
static int get_xmpp_connection_server_alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	struct uci_section *dmmap_section = NULL;

	get_dmmap_section_of_config_section("dmmap_xmpp", "connection_server", section_name((struct uci_section *)data), &dmmap_section);
	dmuci_get_value_by_section_string(dmmap_section, "con_srv_alias", value);
	if ((*value)[0] == '\0')
		dmasprintf(value, "cpe-%s", instance);
	return 0;
}

static int set_xmpp_connection_server_alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	struct uci_section *dmmap_section = NULL;

	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			get_dmmap_section_of_config_section("dmmap_xmpp", "connection_server", section_name((struct uci_section *)data), &dmmap_section);
			dmuci_set_value_by_section(dmmap_section, "con_srv_alias", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Server.{i}.ServerAddress!UCI:xmpp/xmpp_connection,@i-1/server_address*/
static int get_xmpp_connection_server_server_address(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "server_address", value);
	return 0;
}

static int set_xmpp_connection_server_server_address(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "server_address", value);
			return 0;
	}
	return 0;
}

/*#Device.XMPP.Connection.{i}.Server.{i}.Port!UCI:xmpp/xmpp_connection,@i-1/port*/
static int get_xmpp_connection_server_port(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "port", "5222");
	return 0;
}

static int set_xmpp_connection_server_port(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"0","65535"}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "port", value);
			return 0;
	}
	return 0;
}

/*************************************************************
* ENTRY METHOD
**************************************************************/
/*#Device.XMPP.Connection.{i}.!UCI:xmpp/xmpp_connection/dmmap_cwmp_xmpp*/
static int browsexmpp_connectionInst(struct dmctx *dmctx, DMNODE *parent_node, void *prev_data, char *prev_instance)
{
	char *inst, *max_inst = NULL;
	struct dmmap_dup *p;
	LIST_HEAD(dup_list);

	synchronize_specific_config_sections_with_dmmap("xmpp", "connection", "dmmap_xmpp", &dup_list);
	list_for_each_entry(p, &dup_list, list) {

		inst = handle_update_instance(1, dmctx, &max_inst, update_instance_alias, 3,
			   p->dmmap_section, "con_inst", "con_alias");

		if (DM_LINK_INST_OBJ(dmctx, parent_node, (void *)p->config_section, inst) == DM_STOP)
			break;
	}
	free_dmmap_config_dup_list(&dup_list);
	return 0;

}

/*#Device.XMPP.Connection.{i}.!UCI:xmpp/xmpp_connection_server/dmmap_cwmp_xmpp*/
static int browsexmpp_connection_serverInst(struct dmctx *dmctx, DMNODE *parent_node, void *prev_data, char *prev_instance)
{
	char *inst, *max_inst = NULL, *con_id;
	struct dmmap_dup *p;
	LIST_HEAD(dup_list);

	dmuci_get_value_by_section_string((struct uci_section *)prev_data, "xmpp_id", &con_id);
	synchronize_specific_config_sections_with_dmmap_eq("xmpp", "connection_server", "dmmap_xmpp", "con_id", con_id, &dup_list);

	list_for_each_entry(p, &dup_list, list) {

		inst = handle_update_instance(2, dmctx, &max_inst, update_instance_alias, 3,
			   p->dmmap_section, "con_srv_inst", "con_srv_alias");

		if (DM_LINK_INST_OBJ(dmctx, parent_node, (void *)p->config_section, inst) == DM_STOP)
			break;
	}
	free_dmmap_config_dup_list(&dup_list);
	return 0;
}

/* *** Device.XMPP. *** */
DMOBJ tDeviceXMPPObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"XMPP", &DMREAD, NULL, NULL, NULL, NULL, NULL, tXMPPObj, tXMPPParams, NULL, BBFDM_BOTH},
{0}
};

DMOBJ tXMPPObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"Connection", &DMWRITE, add_xmpp_connection, delete_xmpp_connection, NULL, browsexmpp_connectionInst, NULL, tXMPPConnectionObj, tXMPPConnectionParams, NULL, BBFDM_BOTH, LIST_KEY{"Alias", "Username", "Domain", "Resource", NULL}},
{0}
};

DMLEAF tXMPPParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"ConnectionNumberOfEntries", &DMREAD, DMT_UNINT, get_xmpp_connection_nbr_entry, NULL, BBFDM_BOTH},
{"SupportedServerConnectAlgorithms", &DMREAD, DMT_STRING, get_xmpp_connection_supported_server_connect_algorithms, NULL, BBFDM_BOTH},
{0}
};

/* *** Device.XMPP.Connection.{i}. *** */
DMOBJ tXMPPConnectionObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"Server", &DMREAD, NULL, NULL, NULL, browsexmpp_connection_serverInst, NULL, NULL, tXMPPConnectionServerParams, NULL, BBFDM_BOTH, LIST_KEY{"Alias", "ServerAddress", "Port", NULL}},
{0}
};

DMLEAF tXMPPConnectionParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Enable", &DMWRITE, DMT_BOOL, get_connection_enable, set_connection_enable, BBFDM_BOTH},
{"Alias", &DMWRITE, DMT_STRING, get_xmpp_connection_alias, set_xmpp_connection_alias, BBFDM_BOTH},
{"Username", &DMWRITE, DMT_STRING, get_xmpp_connection_username, set_xmpp_connection_username, BBFDM_BOTH},
{"Password", &DMWRITE, DMT_STRING, get_xmpp_connection_password, set_xmpp_connection_password, BBFDM_BOTH},
{"Domain", &DMWRITE, DMT_STRING, get_xmpp_connection_domain, set_xmpp_connection_domain, BBFDM_BOTH},
{"Resource", &DMWRITE, DMT_STRING, get_xmpp_connection_resource, set_xmpp_connection_resource, BBFDM_BOTH},
{"ServerConnectAlgorithm", &DMWRITE, DMT_STRING, get_xmpp_connection_server_connect_algorithm, set_xmpp_connection_server_connect_algorithm, BBFDM_BOTH},
{"KeepAliveInterval", &DMWRITE, DMT_LONG, get_xmpp_connection_keepalive_interval, set_xmpp_connection_keepalive_interval, BBFDM_BOTH},
{"ServerConnectAttempts", &DMWRITE, DMT_UNINT, get_xmpp_connection_server_attempts, set_xmpp_connection_server_attempts, BBFDM_BOTH},
{"ServerRetryInitialInterval", &DMWRITE, DMT_UNINT, get_xmpp_connection_retry_initial_interval, set_xmpp_connection_retry_initial_interval, BBFDM_BOTH},
{"ServerRetryIntervalMultiplier", &DMWRITE, DMT_UNINT, get_xmpp_connection_retry_interval_multiplier, set_xmpp_connection_retry_interval_multiplier, BBFDM_BOTH},
{"ServerRetryMaxInterval", &DMWRITE, DMT_UNINT, get_xmpp_connection_retry_max_interval, set_xmpp_connection_retry_max_interval, BBFDM_BOTH},
{"UseTLS", &DMWRITE, DMT_BOOL, get_xmpp_connection_server_usetls, set_xmpp_connection_server_usetls, BBFDM_BOTH},
{"JabberID", &DMREAD, DMT_STRING, get_xmpp_connection_jabber_id, NULL, BBFDM_BOTH},
{"Status", &DMREAD, DMT_STRING, get_xmpp_connection_status, NULL, BBFDM_BOTH},
{"ServerNumberOfEntries", &DMREAD, DMT_UNINT, get_xmpp_connection_server_number_of_entries, NULL, BBFDM_BOTH},
{0}
};

/* *** Device.XMPP.Connection.{i}.Server.{i}. *** */
DMLEAF tXMPPConnectionServerParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Enable", &DMWRITE, DMT_BOOL, get_xmpp_connection_server_enable, set_xmpp_connection_server_enable, BBFDM_BOTH},
{"Alias", &DMWRITE, DMT_STRING, get_xmpp_connection_server_alias, set_xmpp_connection_server_alias, BBFDM_BOTH},
{"ServerAddress", &DMWRITE, DMT_STRING, get_xmpp_connection_server_server_address, set_xmpp_connection_server_server_address, BBFDM_BOTH},
{"Port", &DMWRITE, DMT_UNINT, get_xmpp_connection_server_port, set_xmpp_connection_server_port, BBFDM_BOTH},
{0}
};
