/*
 * Copyright (c) 2017 Genexis B.V.
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

#ifndef _SK9822_BB_H_
#define _SK9822_BB_H_

#include <linux/types.h>

#include "sk9822.h"

void sk9822_bb_write(struct sk9822_leds *sk9822, uint8_t c);

#endif /* _SK9822_BB_H_ */
