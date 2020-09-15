/*
 * Copyright (C) 2020 iopsys Software Solutions AB
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 2.1
 * as published by the Free Software Foundation
 *
 *		Author: Amin Ben Ramdhane <amin.benramdhane@pivasoftware.com>
 */

#ifndef _BULKDATA_H_
#define _BULKDATA_H_

#include <libbbf_api/dmcommon.h>

extern DMOBJ tDeviceBulkDataObj[];
extern DMOBJ tBulkDataObj[];
extern DMLEAF tBulkDataParams[];
extern DMOBJ tBulkDataProfileObj[];
extern DMLEAF tBulkDataProfileParams[];
extern DMLEAF tBulkDataProfileParameterParams[];
extern DMLEAF tBulkDataProfileCSVEncodingParams[];
extern DMLEAF tBulkDataProfileJSONEncodingParams[];
extern DMOBJ tBulkDataProfileHTTPObj[];
extern DMLEAF tBulkDataProfileHTTPParams[];
extern DMLEAF tBulkDataProfileHTTPRequestURIParameterParams[];

#endif //__BULKDATA_H_

