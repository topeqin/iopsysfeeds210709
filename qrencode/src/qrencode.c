/*
 * qrencode - QR Code encoder
 *
 * Copyright (C) 2006, 2007, 2008 Kentaro Fukuchi <fukuchi@megaui.net>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "qrencode.h"
#include "qrencode_inner.h"
#include "qrspec.h"
#include "bitstream.h"
#include "qrinput.h"
#include "rscode.h"
#include "split.h"
#include "mask.h"

/******************************************************************************
 * Raw code
 *****************************************************************************/

static void RSblock_init(RSblock *block, int dl, unsigned char *data, int el)
{
	RS *rs;

	block->dataLength = dl;
	block->data = data;
	block->eccLength = el;
	block->ecc = (unsigned char *)malloc(el);

	rs = init_rs(8, 0x11d, 0, 1, el, 255 - dl - el);
	encode_rs_char(rs, data, block->ecc);
}

QRRawCode *QRraw_new(QRinput *input)
{
	QRRawCode *raw;
	int *spec;
	int i;
	RSblock *rsblock;
	unsigned char *p;

	p = QRinput_getByteStream(input);
	if(p == NULL) {
		return NULL;
	}

	raw = (QRRawCode *)malloc(sizeof(QRRawCode));
	raw->datacode = p;
	spec = QRspec_getEccSpec(input->version, input->level);
	if(spec == NULL) {
		free(raw);
		return NULL;
	}
	raw->version = input->version;
	raw->blocks = QRspec_rsBlockNum(spec);
	raw->rsblock = (RSblock *)malloc(sizeof(RSblock) * raw->blocks);

	rsblock = raw->rsblock;
	p = raw->datacode;
	for(i=0; i<QRspec_rsBlockNum1(spec); i++) {
		RSblock_init(rsblock, QRspec_rsDataCodes1(spec), p,
						QRspec_rsEccCodes1(spec));
		p += QRspec_rsDataCodes1(spec);
		rsblock++;
	}
	for(i=0; i<QRspec_rsBlockNum2(spec); i++) {
		RSblock_init(rsblock, QRspec_rsDataCodes2(spec), p,
						QRspec_rsEccCodes2(spec));
		p += QRspec_rsDataCodes2(spec);
		rsblock++;
	}

	raw->b1 = QRspec_rsBlockNum1(spec);
	raw->dataLength = QRspec_rsBlockNum1(spec) * QRspec_rsDataCodes1(spec)
					+ QRspec_rsBlockNum2(spec) * QRspec_rsDataCodes2(spec);
	raw->eccLength = QRspec_rsBlockNum(spec) * QRspec_rsEccCodes1(spec);
	raw->count = 0;

	free(spec);

	return raw;
}

/**
 * Return a code (byte).
 * This function can be called iteratively.
 * @param raw raw code.
 * @return code
 */
unsigned char QRraw_getCode(QRRawCode *raw)
{
	int col, row;
	unsigned char ret;

	if(raw->count < raw->dataLength) {
		row = raw->count % raw->blocks;
		col = raw->count / raw->blocks;
		if(col >= raw->rsblock[row].dataLength) {
			row += raw->b1;
		}
		ret = raw->rsblock[row].data[col];
	} else if(raw->count < raw->dataLength + raw->eccLength) {
		row = (raw->count - raw->dataLength) % raw->blocks;
		col = (raw->count - raw->dataLength) / raw->blocks;
		ret = raw->rsblock[row].ecc[col];
	} else {
		return 0;
	}
	raw->count++;
	return ret;
}

void QRraw_free(QRRawCode *raw)
{
	int i;

	free(raw->datacode);
	for(i=0; i<raw->blocks; i++) {
		free(raw->rsblock[i].ecc);
	}
	free(raw->rsblock);
	free(raw);
}

/******************************************************************************
 * Frame filling
 *****************************************************************************/

typedef struct {
	int width;
	unsigned char *frame;
	int x, y;
	int dir;
	int bit;
} FrameFiller;

static FrameFiller *FrameFiller_new(int width, unsigned char *frame)
{
	FrameFiller *filler;

	filler = (FrameFiller *)malloc(sizeof(FrameFiller));
	filler->width = width;
	filler->frame = frame;
	filler->x = width - 1;
	filler->y = width - 1;
	filler->dir = -1;
	filler->bit = -1;

	return filler;
}

static unsigned char *FrameFiller_next(FrameFiller *filler)
{
	unsigned char *p;
	int x, y, w;

	if(filler->bit == -1) {
		filler->bit = 0;
		return filler->frame + filler->y * filler->width + filler->x;
	}

	x = filler->x;
	y = filler->y;
	p = filler->frame;
	w = filler->width;

	if(filler->bit == 0) {
		x--;
		filler->bit++;
	} else {
		x++;
		y += filler->dir;
		filler->bit--;
	}

	if(filler->dir < 0) {
		if(y < 0) {
			y = 0;
			x -= 2;
			filler->dir = 1;
			if(x == 6) {
				x--;
				y = 9;
			}
		}
	} else {
		if(y == w) {
			y = w - 1;
			x -= 2;
			filler->dir = -1;
			if(x == 6) {
				x--;
				y -= 8;
			}
		}
	}
	if(x < 0 || y < 0) return NULL;

	filler->x = x;
	filler->y = y;

	if(p[y * w + x] & 0x80) {
		// This tail recursion could be optimized.
		return FrameFiller_next(filler);
	}
	return &p[y * w + x];
}

#if 0
unsigned char *FrameFiller_fillerTest(int version)
{
	int width, length;
	unsigned char *frame, *p;
	FrameFiller *filler;
	int i, j;
	unsigned char cl = 1;
	unsigned char ch = 0;

	width = QRspec_getWidth(version);
	frame = QRspec_newFrame(version);
	filler = FrameFiller_new(width, frame);
	length = QRspec_getDataLength(version, QR_ECLEVEL_L)
			+ QRspec_getECCLength(version, QR_ECLEVEL_L);

	for(i=0; i<length; i++) {
		for(j=0; j<8; j++) {
			p = FrameFiller_next(filler);
			*p = ch | cl;
			cl++;
			if(cl == 9) {
				cl = 1;
				ch += 0x10;
			}
		}
	}
	length = QRspec_getRemainder(version);
	for(i=0; i<length; i++) {
		p = FrameFiller_next(filler);
		*p = 0xa0;
	}
	p = FrameFiller_next(filler);
	free(filler);
	if(p != NULL) {
		return NULL;
	}

	return frame;
}
#endif

/******************************************************************************
 * Format information
 *****************************************************************************/

int QRcode_writeFormatInformation(int width, unsigned char *frame, int mask, QRecLevel level)
{
	unsigned int format;
	unsigned char v;
	int i;
	int blacks = 0;

	format =  QRspec_getFormatInfo(mask, level);

	for(i=0; i<8; i++) {
		if(format & 1) {
			blacks += 2;
			v = 0x85;
		} else {
			v = 0x84;
		}
		frame[width * 8 + width - 1 - i] = v;
		if(i < 6) {
			frame[width * i + 8] = v;
		} else {
			frame[width * (i + 1) + 8] = v;
		}
		format= format >> 1;
	}
	for(i=0; i<7; i++) {
		if(format & 1) {
			blacks += 2;
			v = 0x85;
		} else {
			v = 0x84;
		}
		frame[width * (width - 7 + i) + 8] = v;
		if(i == 0) {
			frame[width * 8 + 7] = v;
		} else {
			frame[width * 8 + 6 - i] = v;
		}
		format= format >> 1;
	}

	return blacks;
}

/******************************************************************************
 * QR-code encoding
 *****************************************************************************/

static QRcode *QRcode_new(int version, int width, unsigned char *data)
{
	QRcode *qrcode;

	qrcode = (QRcode *)malloc(sizeof(QRcode));
	qrcode->version = version;
	qrcode->width = width;
	qrcode->data = data;

	return qrcode;
}

void QRcode_free(QRcode *qrcode)
{
	if(qrcode == NULL) return;

	if(qrcode->data != NULL) {
		free(qrcode->data);
	}
	free(qrcode);
}

QRcode *QRcode_encodeMask(QRinput *input, int mask)
{
	int width, version;
	QRRawCode *raw;
	unsigned char *frame, *masked, *p, code, bit;
	FrameFiller *filler;
	int i, j;
	QRcode *qrcode;

	if(input->version < 0 || input->version > QRSPEC_VERSION_MAX) {
		errno = EINVAL;
		return NULL;
	}
	if(input->level < QR_ECLEVEL_L || input->level > QR_ECLEVEL_H) {
		errno = EINVAL;
		return NULL;
	}

	raw = QRraw_new(input);
	if(raw == NULL) return NULL;

	version = raw->version;
	width = QRspec_getWidth(version);
	frame = QRspec_newFrame(version);
	filler = FrameFiller_new(width, frame);

	/* inteleaved data and ecc codes */
	for(i=0; i<raw->dataLength + raw->eccLength; i++) {
		code = QRraw_getCode(raw);
		bit = 0x80;
		for(j=0; j<8; j++) {
			p = FrameFiller_next(filler);
			*p = 0x02 | ((bit & code) != 0);
			bit = bit >> 1;
		}
	}
	QRraw_free(raw);
	/* remainder bits */
	j = QRspec_getRemainder(version);
	for(i=0; i<j; i++) {
		p = FrameFiller_next(filler);
		*p = 0x02;
	}
	free(filler);
	/* masking */
	if(mask < 0) {
		masked = Mask_mask(width, frame, input->level);
	} else {
		masked = Mask_makeMask(width, frame, mask);
		QRcode_writeFormatInformation(width, masked, mask, input->level);
	}
	qrcode = QRcode_new(version, width, masked);

	free(frame);

	return qrcode;
}

QRcode *QRcode_encodeInput(QRinput *input)
{
	return QRcode_encodeMask(input, -1);
}

QRcode *QRcode_encodeString8bit(const char *string, int version, QRecLevel level)
{
	QRinput *input;
	QRcode *code;

	input = QRinput_new2(version, level);
	if(input == NULL) return NULL;

	QRinput_append(input, QR_MODE_8, strlen(string), (unsigned char *)string);
	code = QRcode_encodeInput(input);
	QRinput_free(input);

	return code;
}

QRcode *QRcode_encodeString(const char *string, int version, QRecLevel level, QRencodeMode hint, int casesensitive)
{
	QRinput *input;
	QRcode *code;
	int ret;

	if(hint != QR_MODE_8 && hint != QR_MODE_KANJI) {
		errno = EINVAL;
		return NULL;
	}

	input = QRinput_new2(version, level);
	if(input == NULL) return NULL;

	ret = Split_splitStringToQRinput(string, input, hint, casesensitive);
	if(ret < 0) {
		QRinput_free(input);
		return NULL;
	}

	code = QRcode_encodeInput(input);
	QRinput_free(input);

	return code;
}

/******************************************************************************
 * Structured QR-code encoding
 *****************************************************************************/

static QRcode_List *QRcode_List_newEntry(void)
{
	QRcode_List *entry;

	entry = (QRcode_List *)malloc(sizeof(QRcode_List));
	if(entry == NULL) return NULL;

	entry->next = NULL;
	entry->code = NULL;

	return entry;
}

static void QRcode_List_freeEntry(QRcode_List *entry)
{
	if(entry->code != NULL) QRcode_free(entry->code);
	free(entry);
}

void QRcode_List_free(QRcode_List *qrlist)
{
	QRcode_List *list = qrlist, *next;

	while(list != NULL) {
		next = list->next;
		QRcode_List_freeEntry(list);
		list = next;
	}
}

int QRcode_List_size(QRcode_List *qrlist)
{
	QRcode_List *list = qrlist;
	int size = 0;

	while(list != NULL) {
		size++;
		list = list->next;
	}

	return size;
}

#if 0
static unsigned char QRcode_parity(const char *str, int size)
{
	unsigned char parity = 0;
	int i;

	for(i=0; i<size; i++) {
		parity ^= str[i];
	}

	return parity;
}
#endif

QRcode_List *QRcode_encodeInputStructured(QRinput_Struct *s)
{
	QRcode_List *head = NULL;
	QRcode_List *tail = NULL;
	QRinput_InputList *list = s->head;

	while(list != NULL) {
		if(head == NULL) {
			head = QRcode_List_newEntry();
			tail = head;
		} else {
			tail->next = QRcode_List_newEntry();
			tail = tail->next;
		}
		tail->code = QRcode_encodeInput(list->input);
		if(tail->code == NULL) {
			QRcode_List_free(head);
			return NULL;
		}
		list = list->next;
	}

	return head;
}

static QRcode_List *QRcode_encodeInputToStructured(QRinput *input)
{
	QRinput_Struct *s;
	QRcode_List *codes;

	s = QRinput_splitQRinputToStruct(input);
	if(s == NULL) return NULL;

	codes = QRcode_encodeInputStructured(s);
	QRinput_Struct_free(s);

	return codes;
}

QRcode_List *QRcode_encodeString8bitStructured(const char *string, int version, QRecLevel level)
{
	QRinput *input;
	QRcode_List *codes;
	int ret;

	if(version <= 0) return NULL;

	input = QRinput_new2(version, level);
	if(input == NULL) return NULL;

	ret = QRinput_append(input, QR_MODE_8, strlen(string), (unsigned char *)string);
	if(ret < 0) {
		QRinput_free(input);
		return NULL;
	}
	codes = QRcode_encodeInputToStructured(input);
	QRinput_free(input);

	return codes;
}

QRcode_List *QRcode_encodeStringStructured(const char *string, int version, QRecLevel level, QRencodeMode hint, int casesensitive)
{
	QRinput *input;
	QRcode_List *codes;
	int ret;

	if(version <= 0) return NULL;
	if(hint != QR_MODE_8 && hint != QR_MODE_KANJI) {
		return NULL;
	}

	input = QRinput_new2(version, level);
	if(input == NULL) return NULL;

	ret = Split_splitStringToQRinput(string, input, hint, casesensitive);
	if(ret < 0) {
		QRinput_free(input);
		return NULL;
	}
	codes = QRcode_encodeInputToStructured(input);
	QRinput_free(input);

	return codes;
}
