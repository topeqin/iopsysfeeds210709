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
{"Device.IP.Interface.", tDeviceTWAMPReflectorObj},
{0}
};

static char *get_last_instance_with_option(char *package, char *section, char *option, char *val, char *opt_inst)
{
	struct uci_section *s;
	char *inst = NULL;

	uci_foreach_option_eq(package, section, option, val, s) {
		inst = update_instance(inst, 4, s, opt_inst, package, section);
	}
	return inst;
}

static char *get_last_id(char *package, char *section)
{
	struct uci_section *s;
	char *id;
	int cnt = 0;

	uci_foreach_sections(package, section, s) {
		cnt++;
	}
	dmasprintf(&id, "%d", cnt+1);
	return id;
}

struct ip_args
{
	struct uci_section *ip_sec;
	char *ip_4address;
};

static int addObjIPInterfaceTWAMPReflector(char *refparam, struct dmctx *ctx, void *data, char **instance)
{
	struct uci_section *connection;
	char *value1, *last_inst, *id;

	last_inst = get_last_instance_with_option("twamp", "twamp_reflector", "interface", section_name(((struct ip_args *)data)->ip_sec), "twamp_inst");
	id = get_last_id("twamp", "twamp_reflector");
	dmuci_add_section("twamp", "twamp_reflector", &connection, &value1);
	dmasprintf(instance, "%d", last_inst?atoi(last_inst)+1:1);
	dmuci_set_value_by_section(connection, "twamp_inst", *instance);
	dmuci_set_value_by_section(connection, "id", id);
	dmuci_set_value_by_section(connection, "enable", "0");
	dmuci_set_value_by_section(connection, "interface", section_name(((struct ip_args *)data)->ip_sec));
	dmuci_set_value_by_section(connection, "port", "862");
	dmuci_set_value_by_section(connection, "max_ttl", "1");
	return 0;
}

static int delObjIPInterfaceTWAMPReflector(char *refparam, struct dmctx *ctx, void *data, char *instance, unsigned char del_action)
{
	int found = 0;
	struct uci_section *s, *ss = NULL;
	char *interface;
	struct uci_section *section = (struct uci_section *)data;

	switch (del_action) {
		case DEL_INST:
			dmuci_delete_by_section(section, NULL, NULL);
			return 0;
		case DEL_ALL:
			uci_foreach_sections("twamp", "twamp_reflector", s) {
				dmuci_get_value_by_section_string(s, "interface", &interface);
				if(strcmp(interface, section_name(((struct ip_args *)data)->ip_sec)) != 0)
					continue;
				if (found != 0) {
					dmuci_delete_by_section(ss, NULL, NULL);
				}
				ss = s;
				found++;
			}
			if (ss != NULL) {
				dmuci_delete_by_section(ss, NULL, NULL);
			}
			return 0;
	}
	return 0;
}

static int get_IPInterfaceTWAMPReflector_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "enable", "1");
	return 0;
}

static int set_IPInterfaceTWAMPReflector_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;
	struct uci_section *s;
	char *interface, *device, *id, *ipv4addr = "";
	json_object *res, *jobj;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			break;
		case VALUESET:
			string_to_bool(value, &b);
			if(b) {
				dmuci_get_value_by_section_string((struct uci_section *)data, "interface", &interface);
				dmuci_get_value_by_section_string((struct uci_section *)data, "id", &id);
				dmuci_set_value_by_section((struct uci_section *)data, "enable", "1");
				dmuci_set_value("twamp", "twamp", "id", id);
				uci_foreach_sections("network", "interface", s) {
					if(strcmp(section_name(s), interface) != 0)
						continue;
					dmuci_get_value_by_section_string(s, "ipaddr", &ipv4addr);
					break;
				}
				if (ipv4addr[0] == '\0') {
					dmubus_call("network.interface", "status", UBUS_ARGS{{"interface", interface, String}}, 1, &res);
					if (res) {
						jobj = dmjson_select_obj_in_array_idx(res, 0, 1, "ipv4-address");
						ipv4addr = dmjson_get_value(jobj, 1, "address");
						if (ipv4addr[0] == '\0')
							dmuci_set_value_by_section((struct uci_section *)data, "ip_version", "6");
						else
							dmuci_set_value_by_section((struct uci_section *)data, "ip_version", "4");
					}
				} else
					dmuci_set_value_by_section((struct uci_section *)data, "ip_version", "4");
				dmubus_call("network.interface", "status", UBUS_ARGS{{"interface", interface, String}}, 1, &res);
				if (res) {
					device = dmjson_get_value(res, 1, "device");
					dmuci_set_value_by_section((struct uci_section *)data, "device", device);
				}
				dmuci_set_value_by_section((struct uci_section *)data, "device", get_device(interface));
			} else {
				dmuci_set_value_by_section((struct uci_section *)data, "enable", "0");
			}
			break;
	}
	return 0;
}

static int get_IPInterfaceTWAMPReflector_Status(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	char *enable;

	dmuci_get_value_by_section_string((struct uci_section *)data, "enable", &enable);
	if (strcmp(enable, "1") == 0)
		*value = "Active";
	else
		*value = "Disabled";
	return 0;
}

static int get_IPInterfaceTWAMPReflector_Alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "twamp_alias", value);
	if ((*value)[0] == '\0')
		dmasprintf(value, "cpe-%s", instance);
	return 0;
}

static int set_IPInterfaceTWAMPReflector_Alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "twamp_alias", value);
			break;
	}
	return 0;
}

static int get_IPInterfaceTWAMPReflector_Port(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "port", "862");
	return 0;
}

static int set_IPInterfaceTWAMPReflector_Port(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{NULL,"65535"}}, 1))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "port", value);
			break;
	}
	return 0;
}

static int get_IPInterfaceTWAMPReflector_MaximumTTL(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "max_ttl", "1");
	return 0;
}

static int set_IPInterfaceTWAMPReflector_MaximumTTL(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1","255"}}, 1))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "max_ttl", value);
			break;
	}
	return 0;
}

static int get_IPInterfaceTWAMPReflector_IPAllowedList(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "ip_list", value);
	return 0;
}

static int set_IPInterfaceTWAMPReflector_IPAllowedList(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string_list(value, -1, -1, 255, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "ip_list", value);
			break;
	}
	return 0;
}

static int get_IPInterfaceTWAMPReflector_PortAllowedList(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "port_list", value);
	return 0;
}

static int set_IPInterfaceTWAMPReflector_PortAllowedList(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string_list(value, -1, -1, 255, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "port_list", value);
			break;
	}
	return 0;
}

static int browseIPInterfaceTWAMPReflectorInst(struct dmctx *dmctx, DMNODE *parent_node, void *prev_data, char *prev_instance)
{
	struct uci_section *s = NULL;
	char *inst = NULL, *max_inst = NULL;

	uci_foreach_option_eq("twamp", "twamp_reflector", "interface", section_name(((struct ip_args *)prev_data)->ip_sec), s) {

		inst = handle_update_instance(2, dmctx, &max_inst, update_instance_alias, 5,
			   s, "twamp_inst", "twamp_alias", "twamp", "twamp_reflector");

		if (DM_LINK_INST_OBJ(dmctx, parent_node, (void *)s, inst) == DM_STOP)
			break;
	}
	return 0;
}

/* *** Device.IP.Interface. *** */
DMOBJ tDeviceTWAMPReflectorObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"TWAMPReflector", &DMWRITE, addObjIPInterfaceTWAMPReflector, delObjIPInterfaceTWAMPReflector, NULL, browseIPInterfaceTWAMPReflectorInst, NULL, NULL, tIPInterfaceTWAMPReflectorParams, NULL, BBFDM_BOTH, LIST_KEY{"Alias", "Port", NULL}},
{0}
};

/* *** Device.IP.Interface.{i}.TWAMPReflector.{i}. *** */
DMLEAF tIPInterfaceTWAMPReflectorParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Enable", &DMWRITE, DMT_BOOL, get_IPInterfaceTWAMPReflector_Enable, set_IPInterfaceTWAMPReflector_Enable, BBFDM_BOTH},
{"Status", &DMREAD, DMT_STRING, get_IPInterfaceTWAMPReflector_Status, NULL, BBFDM_BOTH},
{"Alias", &DMWRITE, DMT_STRING, get_IPInterfaceTWAMPReflector_Alias, set_IPInterfaceTWAMPReflector_Alias, BBFDM_BOTH},
{"Port", &DMWRITE, DMT_UNINT, get_IPInterfaceTWAMPReflector_Port, set_IPInterfaceTWAMPReflector_Port, BBFDM_BOTH},
{"MaximumTTL", &DMWRITE, DMT_UNINT, get_IPInterfaceTWAMPReflector_MaximumTTL, set_IPInterfaceTWAMPReflector_MaximumTTL, BBFDM_BOTH},
{"IPAllowedList", &DMWRITE, DMT_STRING, get_IPInterfaceTWAMPReflector_IPAllowedList, set_IPInterfaceTWAMPReflector_IPAllowedList, BBFDM_BOTH},
{"PortAllowedList", &DMWRITE, DMT_STRING, get_IPInterfaceTWAMPReflector_PortAllowedList, set_IPInterfaceTWAMPReflector_PortAllowedList, BBFDM_BOTH},
{0}
};
