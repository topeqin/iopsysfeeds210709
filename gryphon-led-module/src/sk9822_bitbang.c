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

#include <linux/gpio/consumer.h>
#include <linux/delay.h>
#include <linux/types.h>

#include "sk9822.h"

/**
 * @brief Bitbang write operation CLOCK+DATA
 *
 * Assumed state before call: CLOCK- Low, DATA- High
 */
void sk9822_bb_write(struct sk9822_leds *sk9822, uint8_t c)
{
	uint8_t i;

	for (i = 0; i < 8 ; i++) {
		if (!(c&0x80)) {
			gpiod_set_value(sk9822->data_gpio, 0); // set data low
		} else {
			gpiod_set_value(sk9822->data_gpio, 1); // set data high
		}

		gpiod_set_value(sk9822->clock_gpio, 1); // set clock high, data sampled here
		c <<= 1;
		udelay(1); // stretch clock
		gpiod_set_value(sk9822->clock_gpio, 0); // set clock low
	}

	// State after call: SCK Low, Data high
}
