/*
 * Copyright (C) 2020 iopsys Software Solutions AB
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation
 *
 *		Author: Amin Ben Ramdhane <amin.benramdhane@pivasoftware.com>
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
{"Device.", tDeviceBulkDataObj},
{0}
};

/*************************************************************
* ENTRY METHOD
*************************************************************/
/*#Device.BulkData.Profile.{i}.!UCI:bulkdata/profile/dmmap_bulkdata*/
static int browseBulkDataProfileInst(struct dmctx *dmctx, DMNODE *parent_node, void *prev_data, char *prev_instance)
{
	char *inst, *max_inst = NULL;
	struct dmmap_dup *p;
	LIST_HEAD(dup_list);

	synchronize_specific_config_sections_with_dmmap("bulkdata", "profile", "dmmap_bulkdata", &dup_list);
	list_for_each_entry(p, &dup_list, list) {

		inst = handle_update_instance(1, dmctx, &max_inst, update_instance_alias, 5,
			   p->dmmap_section, "profile_instance", "profile_alias", "dmmap_bulkdata", "profile");

		if (DM_LINK_INST_OBJ(dmctx, parent_node, (void *)p->config_section, inst) == DM_STOP)
			break;
	}
	free_dmmap_config_dup_list(&dup_list);
	return 0;
}

/*#Device.BulkData.Profile.{i}.Parameter.{i}.!UCI:bulkdata/profile_parameter/dmmap_bulkdata*/
static int browseBulkDataProfileParameterInst(struct dmctx *dmctx, DMNODE *parent_node, void *prev_data, char *prev_instance)
{
	char *inst = NULL, *max_inst = NULL, *prev_profile_id, *prof_id;
	struct browse_args browse_args = {0};
	struct dmmap_dup *p = NULL;

	LIST_HEAD(dup_list);
	dmuci_get_value_by_section_string((struct uci_section *)prev_data, "profile_id", &prev_profile_id);
	synchronize_specific_config_sections_with_dmmap_eq("bulkdata", "profile_parameter", "dmmap_bulkdata", "profile_id", prev_profile_id, &dup_list);
	list_for_each_entry(p, &dup_list, list) {

		dmuci_get_value_by_section_string(p->dmmap_section, "profile_id", &prof_id);
		if (*prof_id == '\0')
			dmuci_set_value_by_section(p->dmmap_section, "profile_id", prev_profile_id);

		browse_args.option = "profile_id";
		browse_args.value = prev_profile_id;

		inst = handle_update_instance(2, dmctx, &max_inst, update_instance_alias, 7,
			   p->dmmap_section, "parameter_instance", "parameter_alias", "dmmap_bulkdata", "profile_parameter",
			   check_browse_section, (void *)&browse_args);

		if (DM_LINK_INST_OBJ(dmctx, parent_node, (void *)p->config_section, inst) == DM_STOP)
			break;
	}
	free_dmmap_config_dup_list(&dup_list);
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RequestURIParameter.{i}.!UCI:bulkdata/profile_http_request_uri_parameter/dmmap_bulkdata*/
static int browseBulkDataProfileHTTPRequestURIParameterInst(struct dmctx *dmctx, DMNODE *parent_node, void *prev_data, char *prev_instance)
{
	char *inst = NULL, *max_inst = NULL, *prev_profile_id, *prof_id;
	struct browse_args browse_args = {0};
	struct dmmap_dup *p = NULL;

	LIST_HEAD(dup_list);
	dmuci_get_value_by_section_string((struct uci_section *)prev_data, "profile_id", &prev_profile_id);
	synchronize_specific_config_sections_with_dmmap_eq("bulkdata", "profile_http_request_uri_parameter", "dmmap_bulkdata", "profile_id", prev_profile_id, &dup_list);
	list_for_each_entry(p, &dup_list, list) {

		dmuci_get_value_by_section_string(p->dmmap_section, "profile_id", &prof_id);
		if (*prof_id == '\0')
			dmuci_set_value_by_section(p->dmmap_section, "profile_id", prev_profile_id);

		browse_args.option = "profile_id";
		browse_args.value = prev_profile_id;

		inst = handle_update_instance(2, dmctx, &max_inst, update_instance_alias, 7,
			   p->dmmap_section, "requesturiparameter_instance", "requesturiparameter_alias", "dmmap_bulkdata", "profile_http_request_uri_parameter",
			   check_browse_section, (void *)&browse_args);

		if (DM_LINK_INST_OBJ(dmctx, parent_node, (void *)p->config_section, inst) == DM_STOP)
			break;
	}
	free_dmmap_config_dup_list(&dup_list);
	return 0;
}

/*************************************************************
* ADD & DEL OBJ
*************************************************************/
static int addObjBulkDataProfile(char *refparam, struct dmctx *ctx, void *data, char **instance)
{
	struct uci_section *profile, *dmmap_bulkdata;
	char prof_id[16], *last_inst = NULL, *value, *v;

	check_create_dmmap_package("dmmap_bulkdata");
	last_inst = get_last_instance_bbfdm("dmmap_bulkdata", "profile", "profile_instance");
	snprintf(prof_id, sizeof(prof_id), "%d", last_inst ? atoi(last_inst)+1 : 1);

	dmuci_add_section("bulkdata", "profile", &profile, &value);
	dmuci_set_value_by_section(profile, "profile_id", prof_id);
	dmuci_set_value_by_section(profile, "enable", "0");
	dmuci_set_value_by_section(profile, "nbre_of_retained_failed_reports", "0");
	dmuci_set_value_by_section(profile, "protocol", "http");
	dmuci_set_value_by_section(profile, "reporting_interval", "86400");
	dmuci_set_value_by_section(profile, "time_reference", "0");
	dmuci_set_value_by_section(profile, "csv_encoding_field_separator", ",");
	dmuci_set_value_by_section(profile, "csv_encoding_row_separator", "&#10;");
	dmuci_set_value_by_section(profile, "csv_encoding_escape_character", "&quot;");
	dmuci_set_value_by_section(profile, "csv_encoding_report_format", "­column");
	dmuci_set_value_by_section(profile, "csv_encoding_row_time_stamp", "unix");
	dmuci_set_value_by_section(profile, "json_encoding_report_format", "objecthierarchy");
	dmuci_set_value_by_section(profile, "json_encoding_report_time_stamp", "unix");
	dmuci_set_value_by_section(profile, "http_compression", "none");
	dmuci_set_value_by_section(profile, "http_method", "post");
	dmuci_set_value_by_section(profile, "http_use_date_header", "1");
	dmuci_set_value_by_section(profile, "http_retry_enable", "0");
	dmuci_set_value_by_section(profile, "http_retry_minimum_wait_interval", "5");
	dmuci_set_value_by_section(profile, "http_persist_across_reboot", "0");

	dmuci_add_section_bbfdm("dmmap_bulkdata", "profile", &dmmap_bulkdata, &v);
	dmuci_set_value_by_section(dmmap_bulkdata, "section_name", section_name(profile));
	*instance = update_instance(last_inst, 4, dmmap_bulkdata, "profile_instance", "dmmap_bulkdata", "profile");

	return 0;
}

static int delObjBulkDataProfile(char *refparam, struct dmctx *ctx, void *data, char *instance, unsigned char del_action)
{
	struct uci_section *s = NULL, *dmmap_section = NULL, *stmp = NULL;
	char *prev_profile_id;

	switch (del_action) {
		case DEL_INST:
			dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &prev_profile_id);

			// Profile Parameter section
			uci_foreach_option_eq_safe("bulkdata", "profile_parameter", "profile_id", prev_profile_id, stmp, s) {
				
				// Dmmap Profile Parameter section
				get_dmmap_section_of_config_section("dmmap_bulkdata", "profile_parameter", section_name(s), &dmmap_section);
				dmuci_delete_by_section(dmmap_section, NULL, NULL);
				
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// Profile HTTP Request URI Parameter section
			uci_foreach_option_eq_safe("bulkdata", "profile_http_request_uri_parameter", "profile_id", prev_profile_id, stmp, s) {
			
				// dmmap Profile HTTP Request URI Parameter section
				get_dmmap_section_of_config_section("dmmap_bulkdata", "profile_http_request_uri_parameter", section_name(s), &dmmap_section);
				dmuci_delete_by_section(dmmap_section, NULL, NULL);

				dmuci_delete_by_section(s, NULL, NULL);
			}

			// dmmap Profile section
			get_dmmap_section_of_config_section("dmmap_bulkdata", "profile", section_name((struct uci_section *)data), &dmmap_section);
			dmuci_delete_by_section(dmmap_section, NULL, NULL);

			// Profile section
			dmuci_delete_by_section((struct uci_section *)data, NULL, NULL);
			return 0;
		case DEL_ALL:
			// Profile Parameter section
			uci_foreach_sections_safe("bulkdata", "profile_parameter", stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// dmmap Profile Parameter section
			uci_path_foreach_sections_safe(bbfdm, "dmmap_bulkdata", "profile_parameter", stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// Profile HTTP Request URI Parameter section
			uci_foreach_sections_safe("bulkdata", "profile_http_request_uri_parameter", stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// dmmap Profile HTTP Request URI Parameter section
			uci_path_foreach_sections_safe(bbfdm, "dmmap_bulkdata", "profile_http_request_uri_parameter", stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}			

			// Profile section
			uci_foreach_sections_safe("bulkdata", "profile", stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// dmmap Profile section
			uci_path_foreach_sections_safe(bbfdm, "dmmap_bulkdata", "profile", stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			return 0;
	}
	return 0;
}

static int addObjBulkDataProfileParameter(char *refparam, struct dmctx *ctx, void *data, char **instance)
{
	struct uci_section *profile_parameter, *dmmap_bulkdata;
	char *value, *last_inst, *prev_profile_id, *v;
	struct browse_args browse_args = {0};

	dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &prev_profile_id);

	last_inst = get_last_instance_lev2_bbfdm_dmmap_opt("dmmap_bulkdata", "profile_parameter", "parameter_instance", "profile_id", prev_profile_id);

	dmuci_add_section("bulkdata", "profile_parameter", &profile_parameter, &value);
	dmuci_set_value_by_section(profile_parameter, "profile_id", prev_profile_id);

	browse_args.option = "profile_id";
	browse_args.value = prev_profile_id;

	dmuci_add_section_bbfdm("dmmap_bulkdata", "profile_parameter", &dmmap_bulkdata, &v);
	dmuci_set_value_by_section(dmmap_bulkdata, "section_name", section_name(profile_parameter));
	dmuci_set_value_by_section(dmmap_bulkdata, "profile_id", prev_profile_id);

	*instance = update_instance(last_inst, 6, dmmap_bulkdata, "parameter_instance", "dmmap_bulkdata", "profile_parameter", check_browse_section, (void *)&browse_args);

	return 0;
}

static int delObjBulkDataProfileParameter(char *refparam, struct dmctx *ctx, void *data, char *instance, unsigned char del_action)
{
	struct uci_section *s = NULL, *stmp = NULL;
	char *prev_profile_id;

	switch (del_action) {
		case DEL_INST:
			get_dmmap_section_of_config_section("dmmap_bulkdata", "profile_parameter", section_name((struct uci_section *)data), &s);
			dmuci_delete_by_section(s, NULL, NULL);
			dmuci_delete_by_section((struct uci_section *)data, NULL, NULL);
			return 0;
		case DEL_ALL:
			dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &prev_profile_id);

			// Profile Parameter section
			uci_foreach_option_eq_safe("bulkdata", "profile_parameter", "profile_id", prev_profile_id, stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// dmmap Profile Parameter section
			uci_path_foreach_option_eq_safe(bbfdm, "dmmap_bulkdata", "profile_parameter", "profile_id", prev_profile_id, stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			return 0;
	}
	return 0;
}

static int addObjBulkDataProfileHTTPRequestURIParameter(char *refparam, struct dmctx *ctx, void *data, char **instance)
{
	struct uci_section *profile_http_request_uri_parameter, *dmmap_bulkdata;
	char *value, *last_inst, *prev_profile_id, *v;
	struct browse_args browse_args = {0};

	dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &prev_profile_id);

	last_inst = get_last_instance_lev2_bbfdm_dmmap_opt("dmmap_bulkdata", "profile_http_request_uri_parameter", "requesturiparameter_instance", "profile_id", prev_profile_id);

	dmuci_add_section("bulkdata", "profile_http_request_uri_parameter", &profile_http_request_uri_parameter, &value);
	dmuci_set_value_by_section(profile_http_request_uri_parameter, "profile_id", prev_profile_id);

	browse_args.option = "profile_id";
	browse_args.value = prev_profile_id;

	dmuci_add_section_bbfdm("dmmap_bulkdata", "profile_http_request_uri_parameter", &dmmap_bulkdata, &v);
	dmuci_set_value_by_section(dmmap_bulkdata, "section_name", section_name(profile_http_request_uri_parameter));
	dmuci_set_value_by_section(dmmap_bulkdata, "profile_id", prev_profile_id);

	*instance = update_instance(last_inst, 6, dmmap_bulkdata, "requesturiparameter_instance", "dmmap_bulkdata", "profile_http_request_uri_parameter", check_browse_section, (void *)&browse_args);

	return 0;
}

static int delObjBulkDataProfileHTTPRequestURIParameter(char *refparam, struct dmctx *ctx, void *data, char *instance, unsigned char del_action)
{
	struct uci_section *s = NULL, *stmp = NULL;
	char *prev_profile_id;

	switch (del_action) {
		case DEL_INST:
			get_dmmap_section_of_config_section("dmmap_bulkdata", "profile_http_request_uri_parameter", section_name((struct uci_section *)data), &s);
			dmuci_delete_by_section(s, NULL, NULL);
			dmuci_delete_by_section((struct uci_section *)data, NULL, NULL);
			return 0;
		case DEL_ALL:
			dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &prev_profile_id);

			// Profile Parameter section
			uci_foreach_option_eq_safe("bulkdata", "profile_http_request_uri_parameter", "profile_id", prev_profile_id, stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			// dmmap Profile Parameter section
			uci_path_foreach_option_eq_safe(bbfdm, "dmmap_bulkdata", "profile_http_request_uri_parameter", "profile_id", prev_profile_id, stmp, s) {
				dmuci_delete_by_section(s, NULL, NULL);
			}

			return 0;
	}
	return 0;
}

/*************************************************************
* GET & SET PARAM
*************************************************************/
/*#Device.BulkData.Enable!UCI:bulkdata/bulkdata,bulkdata/enable*/
static int get_BulkData_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_option_value_fallback_def("bulkdata", "bulkdata", "enable", "1");
	return 0;
}

static int set_BulkData_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			break;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value("bulkdata", "bulkdata", "enable", b ? "1" : "0");
			break;
	}
	return 0;
}

/*#Device.BulkData.Status!UCI:bulkdata/bulkdata,bulkdata/enable*/
static int get_BulkData_Status(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_option_value_string("bulkdata", "bulkdata", "enable", value);
	if (strcmp(*value, "1") == 0)
		*value = "Enabled";
	else
		*value = "Disabled";
	return 0;
}

static int get_BulkData_MinReportingInterval(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "0";
	return 0;
}

static int get_BulkData_Protocols(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "HTTP";
	return 0;
}

static int get_BulkData_EncodingTypes(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "JSON,CSV";
	return 0;
}

static int get_BulkData_ParameterWildCardSupported(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "1";
	return 0;
}

static int get_BulkData_MaxNumberOfProfiles(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "-1";
	return 0;
}

static int get_BulkData_MaxNumberOfParameterReferences(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "-1";
	return 0;
}

/*#Device.BulkData.ProfileNumberOfEntries!UCI:bulkdata/profile/*/
static int get_BulkData_ProfileNumberOfEntries(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	struct uci_section *s = NULL;
	int cnt = 0;

	uci_foreach_sections("bulkdata", "profile", s) {
		cnt++;
	}
	dmasprintf(value, "%d", cnt);
	return 0;
}

/*#Device.BulkData.Profile.{i}.Enable!UCI:bulkdata/profile,@i-1/enable*/
static int get_BulkDataProfile_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "enable", "1");
	return 0;
}

static int set_BulkDataProfile_Enable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			break;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "enable", b ? "1" : "0");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.Alias!UCI:dmmap_bulkdata/profile,@i-1/profile_alias*/
static int get_BulkDataProfile_Alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	struct uci_section *dmmap_section = NULL;

	get_dmmap_section_of_config_section("dmmap_bulkdata", "profile", section_name((struct uci_section *)data), &dmmap_section);
	dmuci_get_value_by_section_string(dmmap_section, "profile_alias", value);
	if ((*value)[0] == '\0')
		dmasprintf(value, "cpe-%s", instance);
	return 0;
}

static int set_BulkDataProfile_Alias(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	struct uci_section *dmmap_section = NULL;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			get_dmmap_section_of_config_section("dmmap_bulkdata", "profile", section_name((struct uci_section *)data), &dmmap_section);
			dmuci_set_value_by_section(dmmap_section, "profile_alias", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.Name!UCI:bulkdata/profile,@i-1/name*/
static int get_BulkDataProfile_Name(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "name", value);
	return 0;
}

static int set_BulkDataProfile_Name(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 255, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "name", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.NumberOfRetainedFailedReports!UCI:bulkdata/profile,@i-1/nbre_of_retained_failed_reports*/
static int get_BulkDataProfile_NumberOfRetainedFailedReports(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "nbre_of_retained_failed_reports", value);
	return 0;
}

static int set_BulkDataProfile_NumberOfRetainedFailedReports(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_int(value, RANGE_ARGS{{"-1",NULL}}, 1))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "nbre_of_retained_failed_reports", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.Protocol!UCI:bulkdata/profile,@i-1/protocol*/
static int get_BulkDataProfile_Protocol(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "protocol", value);
	if (strcmp(*value, "http") == 0)
		*value = "HTTP";
	return 0;
}

static int set_BulkDataProfile_Protocol(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, BulkDataProtocols, 3, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "HTTP") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "protocol", "http");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.EncodingType!UCI:bulkdata/profile,@i-1/encoding_type*/
static int get_BulkDataProfile_EncodingType(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "encoding_type", value);
	if(strcmp(*value, "json") == 0)
		*value = "JSON";
	else if(strcmp(*value, "csv") == 0)
		*value = "CSV";
	return 0;
}

static int set_BulkDataProfile_EncodingType(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, EncodingTypes, 4, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "JSON") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "encoding_type", "json");
			else if(strcmp(value, "CSV") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "encoding_type", "csv");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.ReportingInterval!UCI:bulkdata/profile,@i-1/reporting_interval*/
static int get_BulkDataProfile_ReportingInterval(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "reporting_interval", "86400");
	return 0;
}

static int set_BulkDataProfile_ReportingInterval(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1",NULL}}, 1))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "reporting_interval", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.TimeReference!UCI:bulkdata/profile,@i-1/time_reference*/
static int get_BulkDataProfile_TimeReference(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	time_t time_value;

	dmuci_get_value_by_section_string((struct uci_section *)data, "time_reference", value);
	if ((*value)[0] != '0' && (*value)[0] != '\0') {
		time_value = atoi(*value);
		char s_now[sizeof "AAAA-MM-JJTHH:MM:SSZ"];
		strftime(s_now, sizeof s_now, "%Y-%m-%dT%H:%M:%SZ", localtime(&time_value));
		*value = dmstrdup(s_now);
	} else {
		*value = "0001-01-01T00:00:00Z";
	}
	return 0;
}

static int set_BulkDataProfile_TimeReference(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	struct tm tm;
	char buf[16];

	switch (action) {
		case VALUECHECK:
			if (dm_validate_dateTime(value))
				return FAULT_9007;
			break;
		case VALUESET:
			if (!(strptime(value, "%Y-%m-%dT%H:%M:%S", &tm)))
				break;
			snprintf(buf, sizeof(buf), "%ld", mktime(&tm));
			dmuci_set_value_by_section((struct uci_section *)data, "time_reference", buf);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.ParameterNumberOfEntries!UCI:bulkdata/profile_parameter,false/false*/
static int get_BulkDataProfile_ParameterNumberOfEntries(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	char *profile_id, *curr_profile_id;
	struct uci_section *s = NULL;
	int cnt = 0;

	dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &curr_profile_id);
	uci_foreach_sections("bulkdata", "profile_parameter", s) {
		dmuci_get_value_by_section_string(s, "profile_id", &profile_id);
		if(strcmp(curr_profile_id, profile_id) != 0)
			continue;
		cnt++;
	}
	dmasprintf(value, "%d", cnt);
	return 0;
}

/*#Device.BulkData.Profile.{i}.Parameter.{i}.Name!UCI:bulkdata/profile_parameter,@i-1/name*/
static int get_BulkDataProfileParameter_Name(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "name", value);
	return 0;
}

static int set_BulkDataProfileParameter_Name(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "name", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.Parameter.{i}.Reference!UCI:bulkdata/profile_parameter,@i-1/reference*/
static int get_BulkDataProfileParameter_Reference(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "reference", value);
	return 0;
}

static int set_BulkDataProfileParameter_Reference(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "reference", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.CSVEncoding.FieldSeparator!UCI:bulkdata/profile,@i-1/csv_encoding_field_separator*/
static int get_BulkDataProfileCSVEncoding_FieldSeparator(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "csv_encoding_field_separator", value);
	return 0;
}

static int set_BulkDataProfileCSVEncoding_FieldSeparator(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_field_separator", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.CSVEncoding.RowSeparator!UCI:bulkdata/profile,@i-1/csv_encoding_row_separator*/
static int get_BulkDataProfileCSVEncoding_RowSeparator(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "csv_encoding_row_separator", value);
	return 0;
}

static int set_BulkDataProfileCSVEncoding_RowSeparator(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if((strcmp(value, "&#10;") == 0) || (strcmp(value, "&#13;") == 0))
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_row_separator", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.CSVEncoding.EscapeCharacter!UCI:bulkdata/profile,@i-1/csv_encoding_escape_character*/
static int get_BulkDataProfileCSVEncoding_EscapeCharacter(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "csv_encoding_escape_character", value);
	return 0;
}

static int set_BulkDataProfileCSVEncoding_EscapeCharacter(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "&quot;") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_escape_character", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.CSVEncoding.ReportFormat!UCI:bulkdata/profile,@i-1/csv_encoding_report_format*/
static int get_BulkDataProfileCSVEncoding_ReportFormat(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "csv_encoding_report_format", value);
	if(strcmp(*value, "row") == 0)
		*value = "ParameterPerRow";
	else if(strcmp(*value, "column") == 0)
		*value = "ParameterPerColumn";
	return 0;
}

static int set_BulkDataProfileCSVEncoding_ReportFormat(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, CSVReportFormat, 2, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "ParameterPerRow") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_report_format", "row");
			else if(strcmp(value, "ParameterPerColumn") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_report_format", "column");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.CSVEncoding.RowTimestamp!UCI:bulkdata/profile,@i-1/csv_encoding_row_time_stamp*/
static int get_BulkDataProfileCSVEncoding_RowTimestamp(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "csv_encoding_row_time_stamp", value);
	if(strcmp(*value, "unix") == 0)
		*value = "Unix-Epoch";
	else if(strcmp(*value, "iso8601") == 0)
		*value = "ISO-8601";
	else if(strcmp(*value, "none") == 0)
		*value = "None";
	return 0;
}

static int set_BulkDataProfileCSVEncoding_RowTimestamp(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, RowTimestamp, 3, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "Unix-Epoch") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_row_time_stamp", "unix");
			else if(strcmp(value, "ISO-8601") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_row_time_stamp", "iso8601");
			else if(strcmp(value, "None") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "csv_encoding_row_time_stamp", "none");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.JSONEncoding.ReportFormat!UCI:bulkdata/profile,@i-1/json_encoding_report_format*/
static int get_BulkDataProfileJSONEncoding_ReportFormat(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "json_encoding_report_format", value);
	if(strcmp(*value, "objecthierarchy") == 0)
		*value = "ObjectHierarchy";
	else if(strcmp(*value, "namevaluepair") == 0)
		*value = "NameValuePair";
	return 0;
}

static int set_BulkDataProfileJSONEncoding_ReportFormat(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, JSONReportFormat, 2, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "ObjectHierarchy") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "json_encoding_report_format", "objecthierarchy");
			else if(strcmp(value, "NameValuePair") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "json_encoding_report_format", "namevaluepair");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.JSONEncoding.ReportTimestamp!UCI:bulkdata/profile,@i-1/json_encoding_report_time_stamp*/
static int get_BulkDataProfileJSONEncoding_ReportTimestamp(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "json_encoding_report_time_stamp", value);
	if(strcmp(*value, "unix") == 0)
		*value = "Unix-Epoch";
	else if(strcmp(*value, "iso8601") == 0)
		*value = "ISO-8601";
	else if(strcmp(*value, "none") == 0)
		*value = "None";
	return 0;
}

static int set_BulkDataProfileJSONEncoding_ReportTimestamp(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, RowTimestamp, 3, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "Unix-Epoch") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "json_encoding_report_time_stamp", "unix");
			else if(strcmp(value, "ISO-8601") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "json_encoding_report_time_stamp", "iso8601");
			else if(strcmp(value, "None") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "json_encoding_report_time_stamp", "none");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.URL!UCI:bulkdata/profile,@i-1/http_url*/
static int get_BulkDataProfileHTTP_URL(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "http_url", value);
	return 0;
}

static int set_BulkDataProfileHTTP_URL(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 1024, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "http_url", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.Username!UCI:bulkdata/profile,@i-1/http_username*/
static int get_BulkDataProfileHTTP_Username(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "http_username", value);
	return 0;
}

static int set_BulkDataProfileHTTP_Username(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "http_username", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.Password!UCI:bulkdata/profile,@i-1/http_password*/
static int get_BulkDataProfileHTTP_Password(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "";
	return 0;
}

static int set_BulkDataProfileHTTP_Password(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "http_password", value);
			break;
	}
	return 0;
}

static int get_BulkDataProfileHTTP_CompressionsSupported(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "GZIP,Compress,Deflate";
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.Compression!UCI:bulkdata/profile,@i-1/http_compression*/
static int get_BulkDataProfileHTTP_Compression(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "http_compression", value);
	if(strcmp(*value, "gzip") == 0)
		*value = "GZIP";
	else if(strcmp(*value, "compress") == 0)
		*value = "Compress";
	else if(strcmp(*value, "deflate") == 0)
		*value = "Deflate";
	return 0;
}

static int set_BulkDataProfileHTTP_Compression(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "GZIP") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "http_compression", "gzip");
			else if(strcmp(value, "Compress") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "http_compression", "compress");
			else if(strcmp(value, "Deflate") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "http_compression", "deflate");
			break;
	}
	return 0;
}

static int get_BulkDataProfileHTTP_MethodsSupported(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = "POST,PUT";
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.Method!UCI:bulkdata/profile,@i-1/http_method*/
static int get_BulkDataProfileHTTP_Method(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "http_method", value);
	if(strcmp(*value, "post") == 0)
		*value = "POST";
	else if(strcmp(*value, "put") == 0)
		*value = "PUT";
	return 0;
}

static int set_BulkDataProfileHTTP_Method(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, -1, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			if(strcmp(value, "POST") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "http_method", "post");
			else if(strcmp(value, "PUT") == 0)
				dmuci_set_value_by_section((struct uci_section *)data, "http_method", "put");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.UseDateHeader!UCI:bulkdata/profile,@i-1/http_use_date_header*/
static int get_BulkDataProfileHTTP_UseDateHeader(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "http_use_date_header", "1");
	return 0;
}

static int set_BulkDataProfileHTTP_UseDateHeader(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			break;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "http_use_date_header", b ? "1" : "0");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RetryEnable!UCI:bulkdata/profile,@i-1/http_retry_enable*/
static int get_BulkDataProfileHTTP_RetryEnable(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "http_retry_enable", "1");
	return 0;
}

static int set_BulkDataProfileHTTP_RetryEnable(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			break;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "http_retry_enable", b ? "1" : "0");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RetryMinimumWaitInterval!UCI:bulkdata/profile,@i-1/http_retry_minimum_wait_interval*/
static int get_BulkDataProfileHTTP_RetryMinimumWaitInterval(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "http_retry_minimum_wait_interval", "5");
	return 0;
}

static int set_BulkDataProfileHTTP_RetryMinimumWaitInterval(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1","65535"}}, 1))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "http_retry_minimum_wait_interval", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RetryIntervalMultiplier!UCI:bulkdata/profile,@i-1/http_retry_interval_multiplier*/
static int get_BulkDataProfileHTTP_RetryIntervalMultiplier(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "http_retry_interval_multiplier", "2000");
	return 0;
}

static int set_BulkDataProfileHTTP_RetryIntervalMultiplier(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_unsignedInt(value, RANGE_ARGS{{"1000","65535"}}, 1))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "http_retry_interval_multiplier", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RequestURIParameterNumberOfEntries!UCI:bulkdata/profile_http_request_uri_parameter,false/false*/
static int get_BulkDataProfileHTTP_RequestURIParameterNumberOfEntries(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	char *profile_id, *curr_profile_id;
	struct uci_section *s = NULL;
	int cnt = 0;

	dmuci_get_value_by_section_string((struct uci_section *)data, "profile_id", &curr_profile_id);
	uci_foreach_sections("bulkdata", "profile_http_request_uri_parameter", s) {
		dmuci_get_value_by_section_string(s, "profile_id", &profile_id);
		if(strcmp(curr_profile_id, profile_id) != 0)
			continue;
		cnt++;
	}
	dmasprintf(value, "%d", cnt);
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.PersistAcrossReboot!UCI:bulkdata/profile,@i-1/http_persist_across_reboot*/
static int get_BulkDataProfileHTTP_PersistAcrossReboot(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	*value = dmuci_get_value_by_section_fallback_def((struct uci_section *)data, "http_persist_across_reboot", "1");
	return 0;
}

static int set_BulkDataProfileHTTP_PersistAcrossReboot(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	bool b;

	switch (action)	{
		case VALUECHECK:
			if (dm_validate_boolean(value))
				return FAULT_9007;
			break;
		case VALUESET:
			string_to_bool(value, &b);
			dmuci_set_value_by_section((struct uci_section *)data, "http_persist_across_reboot", b ? "1" : "0");
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RequestURIParameter.{i}.Name!UCI:bulkdata/profile_http_request_uri_parameter,@i-1/name*/
static int get_BulkDataProfileHTTPRequestURIParameter_Name(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "name", value);
	return 0;
}

static int set_BulkDataProfileHTTPRequestURIParameter_Name(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 64, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "name", value);
			break;
	}
	return 0;
}

/*#Device.BulkData.Profile.{i}.HTTP.RequestURIParameter.{i}.Reference!UCI:bulkdata/profile_http_request_uri_parameter,@i-1/reference*/
static int get_BulkDataProfileHTTPRequestURIParameter_Reference(char *refparam, struct dmctx *ctx, void *data, char *instance, char **value)
{
	dmuci_get_value_by_section_string((struct uci_section *)data, "reference", value);
	return 0;
}

static int set_BulkDataProfileHTTPRequestURIParameter_Reference(char *refparam, struct dmctx *ctx, void *data, char *instance, char *value, int action)
{
	switch (action)	{
		case VALUECHECK:
			if (dm_validate_string(value, -1, 256, NULL, 0, NULL, 0))
				return FAULT_9007;
			break;
		case VALUESET:
			dmuci_set_value_by_section((struct uci_section *)data, "reference", value);
			break;
	}
	return 0;
}

/* *** Device.BulkData. *** */
DMOBJ tDeviceBulkDataObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"BulkData", &DMREAD, NULL, NULL, NULL, NULL, NULL, tBulkDataObj, tBulkDataParams, NULL, BBFDM_BOTH},
{0}
};

DMOBJ tBulkDataObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"Profile", &DMWRITE, addObjBulkDataProfile, delObjBulkDataProfile, NULL, browseBulkDataProfileInst, NULL, tBulkDataProfileObj, tBulkDataProfileParams, NULL, BBFDM_BOTH, LIST_KEY{"Alias", NULL}},
{0}
};

DMLEAF tBulkDataParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Enable", &DMWRITE, DMT_BOOL, get_BulkData_Enable, set_BulkData_Enable, BBFDM_BOTH},
{"Status", &DMREAD, DMT_STRING, get_BulkData_Status, NULL, BBFDM_BOTH},
{"MinReportingInterval", &DMREAD, DMT_UNINT, get_BulkData_MinReportingInterval, NULL, BBFDM_BOTH},
{"Protocols", &DMREAD, DMT_STRING, get_BulkData_Protocols, NULL, BBFDM_BOTH},
{"EncodingTypes", &DMREAD, DMT_STRING, get_BulkData_EncodingTypes, NULL, BBFDM_BOTH},
{"ParameterWildCardSupported", &DMREAD, DMT_BOOL, get_BulkData_ParameterWildCardSupported, NULL, BBFDM_BOTH},
{"MaxNumberOfProfiles", &DMREAD, DMT_INT, get_BulkData_MaxNumberOfProfiles, NULL, BBFDM_BOTH},
{"MaxNumberOfParameterReferences", &DMREAD, DMT_INT, get_BulkData_MaxNumberOfParameterReferences, NULL, BBFDM_BOTH},
{"ProfileNumberOfEntries", &DMREAD, DMT_UNINT, get_BulkData_ProfileNumberOfEntries, NULL, BBFDM_BOTH},
{0}
};

/* *** Device.BulkData.Profile.{i}. *** */
DMOBJ tBulkDataProfileObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"Parameter", &DMWRITE, addObjBulkDataProfileParameter, delObjBulkDataProfileParameter, NULL, browseBulkDataProfileParameterInst, NULL, NULL, tBulkDataProfileParameterParams, NULL, BBFDM_BOTH},
{"CSVEncoding", &DMREAD, NULL, NULL, NULL, NULL, NULL, NULL, tBulkDataProfileCSVEncodingParams, NULL, BBFDM_BOTH},
{"JSONEncoding", &DMREAD, NULL, NULL, NULL, NULL, NULL, NULL, tBulkDataProfileJSONEncodingParams, NULL, BBFDM_BOTH},
{"HTTP", &DMREAD, NULL, NULL, NULL, NULL, NULL, tBulkDataProfileHTTPObj, tBulkDataProfileHTTPParams, NULL, BBFDM_BOTH},
{0}
};

DMLEAF tBulkDataProfileParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Enable", &DMWRITE, DMT_BOOL, get_BulkDataProfile_Enable, set_BulkDataProfile_Enable, BBFDM_BOTH},
{"Alias", &DMWRITE, DMT_STRING, get_BulkDataProfile_Alias, set_BulkDataProfile_Alias, BBFDM_BOTH},
{"Name", &DMWRITE, DMT_STRING, get_BulkDataProfile_Name, set_BulkDataProfile_Name, BBFDM_BOTH},
{"NumberOfRetainedFailedReports", &DMWRITE, DMT_INT, get_BulkDataProfile_NumberOfRetainedFailedReports, set_BulkDataProfile_NumberOfRetainedFailedReports, BBFDM_BOTH},
{"Protocol", &DMWRITE, DMT_STRING, get_BulkDataProfile_Protocol, set_BulkDataProfile_Protocol, BBFDM_BOTH},
{"EncodingType", &DMWRITE, DMT_STRING, get_BulkDataProfile_EncodingType, set_BulkDataProfile_EncodingType, BBFDM_BOTH},
{"ReportingInterval", &DMWRITE, DMT_UNINT, get_BulkDataProfile_ReportingInterval, set_BulkDataProfile_ReportingInterval, BBFDM_BOTH},
{"TimeReference", &DMWRITE, DMT_TIME, get_BulkDataProfile_TimeReference, set_BulkDataProfile_TimeReference, BBFDM_BOTH},
{"ParameterNumberOfEntries", &DMREAD, DMT_UNINT, get_BulkDataProfile_ParameterNumberOfEntries, NULL, BBFDM_BOTH},
//{"StreamingHost", &DMWRITE, DMT_STRING, get_BulkDataProfile_StreamingHost, set_BulkDataProfile_StreamingHost, BBFDM_BOTH},
//{"StreamingPort", &DMWRITE, DMT_UNINT, get_BulkDataProfile_StreamingPort, set_BulkDataProfile_StreamingPort, BBFDM_BOTH},
//{"StreamingSessionID", &DMWRITE, DMT_UNINT, get_BulkDataProfile_StreamingSessionID, set_BulkDataProfile_StreamingSessionID, BBFDM_BOTH},
//{"FileTransferURL", &DMWRITE, DMT_STRING, get_BulkDataProfile_FileTransferURL, set_BulkDataProfile_FileTransferURL, BBFDM_BOTH},
//{"FileTransferUsername", &DMWRITE, DMT_STRING, get_BulkDataProfile_FileTransferUsername, set_BulkDataProfile_FileTransferUsername, BBFDM_BOTH},
//{"FileTransferPassword", &DMWRITE, DMT_STRING, get_BulkDataProfile_FileTransferPassword, set_BulkDataProfile_FileTransferPassword, BBFDM_BOTH},
//{"ControlFileFormat", &DMWRITE, DMT_STRING, get_BulkDataProfile_ControlFileFormat, set_BulkDataProfile_ControlFileFormat, BBFDM_BOTH},
//{"Controller", &DMREAD, DMT_STRING, get_BulkDataProfile_Controller, NULL, NULL, NULL, BBFDM_USP},
{0}
};

/* *** Device.BulkData.Profile.{i}.Parameter.{i}. *** */
DMLEAF tBulkDataProfileParameterParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Name", &DMWRITE, DMT_STRING, get_BulkDataProfileParameter_Name, set_BulkDataProfileParameter_Name, BBFDM_BOTH},
{"Reference", &DMWRITE, DMT_STRING, get_BulkDataProfileParameter_Reference, set_BulkDataProfileParameter_Reference, BBFDM_BOTH},
{0}
};

/* *** Device.BulkData.Profile.{i}.CSVEncoding. *** */
DMLEAF tBulkDataProfileCSVEncodingParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"FieldSeparator", &DMWRITE, DMT_STRING, get_BulkDataProfileCSVEncoding_FieldSeparator, set_BulkDataProfileCSVEncoding_FieldSeparator, BBFDM_BOTH},
{"RowSeparator", &DMWRITE, DMT_STRING, get_BulkDataProfileCSVEncoding_RowSeparator, set_BulkDataProfileCSVEncoding_RowSeparator, BBFDM_BOTH},
{"EscapeCharacter", &DMWRITE, DMT_STRING, get_BulkDataProfileCSVEncoding_EscapeCharacter, set_BulkDataProfileCSVEncoding_EscapeCharacter, BBFDM_BOTH},
{"ReportFormat", &DMWRITE, DMT_STRING, get_BulkDataProfileCSVEncoding_ReportFormat, set_BulkDataProfileCSVEncoding_ReportFormat, BBFDM_BOTH},
{"RowTimestamp", &DMWRITE, DMT_STRING, get_BulkDataProfileCSVEncoding_RowTimestamp, set_BulkDataProfileCSVEncoding_RowTimestamp, BBFDM_BOTH},
{0}
};

/* *** Device.BulkData.Profile.{i}.JSONEncoding. *** */
DMLEAF tBulkDataProfileJSONEncodingParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"ReportFormat", &DMWRITE, DMT_STRING, get_BulkDataProfileJSONEncoding_ReportFormat, set_BulkDataProfileJSONEncoding_ReportFormat, BBFDM_BOTH},
{"ReportTimestamp", &DMWRITE, DMT_STRING, get_BulkDataProfileJSONEncoding_ReportTimestamp, set_BulkDataProfileJSONEncoding_ReportTimestamp, BBFDM_BOTH},
{0}
};

/* *** Device.BulkData.Profile.{i}.HTTP. *** */
DMOBJ tBulkDataProfileHTTPObj[] = {
/* OBJ, permission, addobj, delobj, checkdep, browseinstobj, nextdynamicobj, nextobj, leaf, linker, bbfdm_type, uniqueKeys*/
{"RequestURIParameter", &DMWRITE, addObjBulkDataProfileHTTPRequestURIParameter, delObjBulkDataProfileHTTPRequestURIParameter, NULL, browseBulkDataProfileHTTPRequestURIParameterInst, NULL, NULL, tBulkDataProfileHTTPRequestURIParameterParams, NULL, BBFDM_BOTH},
{0}
};

DMLEAF tBulkDataProfileHTTPParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"URL", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTP_URL, set_BulkDataProfileHTTP_URL, BBFDM_BOTH},
{"Username", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTP_Username, set_BulkDataProfileHTTP_Username, BBFDM_BOTH},
{"Password", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTP_Password, set_BulkDataProfileHTTP_Password, BBFDM_BOTH},
{"CompressionsSupported", &DMREAD, DMT_STRING, get_BulkDataProfileHTTP_CompressionsSupported, NULL, BBFDM_BOTH},
{"Compression", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTP_Compression, set_BulkDataProfileHTTP_Compression, BBFDM_BOTH},
{"MethodsSupported", &DMREAD, DMT_STRING, get_BulkDataProfileHTTP_MethodsSupported, NULL, BBFDM_BOTH},
{"Method", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTP_Method, set_BulkDataProfileHTTP_Method, BBFDM_BOTH},
{"UseDateHeader", &DMWRITE, DMT_BOOL, get_BulkDataProfileHTTP_UseDateHeader, set_BulkDataProfileHTTP_UseDateHeader, BBFDM_BOTH},
{"RetryEnable", &DMWRITE, DMT_BOOL, get_BulkDataProfileHTTP_RetryEnable, set_BulkDataProfileHTTP_RetryEnable, BBFDM_BOTH},
{"RetryMinimumWaitInterval", &DMWRITE, DMT_UNINT, get_BulkDataProfileHTTP_RetryMinimumWaitInterval, set_BulkDataProfileHTTP_RetryMinimumWaitInterval, BBFDM_BOTH},
{"RetryIntervalMultiplier", &DMWRITE, DMT_UNINT, get_BulkDataProfileHTTP_RetryIntervalMultiplier, set_BulkDataProfileHTTP_RetryIntervalMultiplier, BBFDM_BOTH},
{"RequestURIParameterNumberOfEntries", &DMREAD, DMT_UNINT, get_BulkDataProfileHTTP_RequestURIParameterNumberOfEntries, NULL, BBFDM_BOTH},
{"PersistAcrossReboot", &DMWRITE, DMT_BOOL, get_BulkDataProfileHTTP_PersistAcrossReboot, set_BulkDataProfileHTTP_PersistAcrossReboot, BBFDM_BOTH},
{0}
};

/* *** Device.BulkData.Profile.{i}.HTTP.RequestURIParameter.{i}. *** */
DMLEAF tBulkDataProfileHTTPRequestURIParameterParams[] = {
/* PARAM, permission, type, getvalue, setvalue, bbfdm_type*/
{"Name", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTPRequestURIParameter_Name, set_BulkDataProfileHTTPRequestURIParameter_Name, BBFDM_BOTH},
{"Reference", &DMWRITE, DMT_STRING, get_BulkDataProfileHTTPRequestURIParameter_Reference, set_BulkDataProfileHTTPRequestURIParameter_Reference, BBFDM_BOTH},
{0}
};


