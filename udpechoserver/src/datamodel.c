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
{"Device.IP.Diagnostics.", tDeviceUDPEchoConfigObj},
{0}
};

static int get_IPDiagnosticsUDPEchoConfig_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_option_value_string("udpechoserver", "udpechoserver", "enable", value);
	return 0;
}

static int set_IPDiagnosticsUDPEchoConfig_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;
	char file[32] = "/var/state/udpechoserver";

	switch (action) {
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			return 0;
		case VALUESET:
			string_to_bool(value, &b);
			if (b) {
				if( access( file, F_OK ) != -1 )
					dmcmd("/bin/rm", 1, file);
				dmuci_set_value("udpechoserver", "udpechoserver", "enable", "1");
			} else
				dmuci_set_value("udpechoserver", "udpechoserver", "enable", "0");
			return 0;
	}
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_Interface(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_option_value_string("udpechoserver", "udpechoserver", "interface", value);
	return 0;
}

static int set_IPDiagnosticsUDPEchoConfig_Interface(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value("udpechoserver", "udpechoserver", "interface", value);
			return 0;
	}
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_SourceIPAddress(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_option_value_string("udpechoserver", "udpechoserver", "address", value);
	return 0;
}

static int set_IPDiagnosticsUDPEchoConfig_SourceIPAddress(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_string(value, -1, 45, NULL, 0, IPAddress, 2))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value("udpechoserver", "udpechoserver", "address", value);
			return 0;
	}
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_UDPPort(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_option_value_string("udpechoserver", "udpechoserver", "server_port", value);
	return 0;
}

static int set_IPDiagnosticsUDPEchoConfig_UDPPort(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action) {
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{NULL,NULL}}, 1))
				return FAULT_9007;
			return 0;
		case VALUESET:
			dmuci_set_value("udpechoserver", "udpechoserver", "server_port", value);
			return 0;
	}
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_EchoPlusEnabled(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_option_value_string("udpechoserver", "udpechoserver", "plus", value);
	return 0;
}

static int set_IPDiagnosticsUDPEchoConfig_EchoPlusEnabled(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action) {
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			return 0;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value("udpechoserver", "udpechoserver", "plus", b ? "1" : "0");
			return 0;
	}
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_EchoPlusSupported(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "true";
	return 0;
}

static inline char *udpechoconfig_get(char *option, char *def)
{
	char *tmp;
	varstate_get_value_string("udpechoserver", "udpechoserver", option, &tmp);
	if(tmp && tmp[0] == '\0')
		return dmstrdup(def);
	else
		return tmp;
}

static int get_IPDiagnosticsUDPEchoConfig_PacketsReceived(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = udpechoconfig_get("PacketsReceived", "0");
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_PacketsResponded(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = udpechoconfig_get("PacketsResponded", "0");
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_BytesReceived(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = udpechoconfig_get("BytesReceived", "0");
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_BytesResponded(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = udpechoconfig_get("BytesResponded", "0");
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_TimeFirstPacketReceived(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = udpechoconfig_get("TimeFirstPacketReceived", "0");
	return 0;
}

static int get_IPDiagnosticsUDPEchoConfig_TimeLastPacketReceived(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = udpechoconfig_get("TimeLastPacketReceived", "0");
	return 0;
}

/* *** Device.IP.Diagnostics. *** */
DMOBJ tDeviceUDPEchoConfigObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, forced_inform, notification, nextdynamicobj, nextobj, leaf, linker, bbfdm_type*/
{"UDPEchoConfig", &DMREAD, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, tIPDiagnosticsUDPEchoConfigParams, NULL, BBFDM_BOTH},
{0}
};

/* *** Device.IP.Diagnostics.UDPEchoConfig. *** */
DMLEAF tIPDiagnosticsUDPEchoConfigParams[] = {
/* PARAM, permission, type, getvalue, setvalue, forced_inform, notification, bbfdm_type*/
{"Enable", &DMWRITE, DMT_BOOL, get_IPDiagnosticsUDPEchoConfig_Enable, set_IPDiagnosticsUDPEchoConfig_Enable, NULL, NULL, BBFDM_BOTH},
{"Interface", &DMWRITE, DMT_STRING, get_IPDiagnosticsUDPEchoConfig_Interface, set_IPDiagnosticsUDPEchoConfig_Interface, NULL, NULL, BBFDM_BOTH},
{"SourceIPAddress", &DMWRITE, DMT_STRING, get_IPDiagnosticsUDPEchoConfig_SourceIPAddress, set_IPDiagnosticsUDPEchoConfig_SourceIPAddress, NULL, NULL, BBFDM_BOTH},
{"UDPPort", &DMWRITE, DMT_UNINT, get_IPDiagnosticsUDPEchoConfig_UDPPort, set_IPDiagnosticsUDPEchoConfig_UDPPort, NULL, NULL, BBFDM_BOTH},
{"EchoPlusEnabled", &DMWRITE, DMT_BOOL, get_IPDiagnosticsUDPEchoConfig_EchoPlusEnabled, set_IPDiagnosticsUDPEchoConfig_EchoPlusEnabled, NULL, NULL, BBFDM_BOTH},
{"EchoPlusSupported", &DMREAD, DMT_BOOL, get_IPDiagnosticsUDPEchoConfig_EchoPlusSupported, NULL, NULL, NULL, BBFDM_BOTH},
{"PacketsReceived", &DMREAD, DMT_UNINT, get_IPDiagnosticsUDPEchoConfig_PacketsReceived, NULL, NULL, NULL, BBFDM_BOTH},
{"PacketsResponded", &DMREAD, DMT_UNINT, get_IPDiagnosticsUDPEchoConfig_PacketsResponded, NULL, NULL, NULL, BBFDM_BOTH},
{"BytesReceived", &DMREAD, DMT_UNINT, get_IPDiagnosticsUDPEchoConfig_BytesReceived, NULL, NULL, NULL, BBFDM_BOTH},
{"BytesResponded", &DMREAD, DMT_UNINT, get_IPDiagnosticsUDPEchoConfig_BytesResponded, NULL, NULL, NULL, BBFDM_BOTH},
{"TimeFirstPacketReceived", &DMREAD, DMT_TIME, get_IPDiagnosticsUDPEchoConfig_TimeFirstPacketReceived, NULL, NULL, NULL, BBFDM_BOTH},
{"TimeLastPacketReceived", &DMREAD, DMT_TIME, get_IPDiagnosticsUDPEchoConfig_TimeLastPacketReceived, NULL, NULL, NULL, BBFDM_BOTH},
{0}
};