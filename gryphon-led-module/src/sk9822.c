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

#include <linux/kernel.h>
#include <linux/types.h>

#include "sk9822.h"
#include "sk9822_bitbang.h"

cRGB __hexs_to_rgb(const char *hex)
{
	cRGB rgb;
	int r, g, b;

	sscanf(hex, "%02x%02x%02x", &r, &g, &b);
	// This needs sanity checking
	rgb.r = r;
	rgb.g = g;
	rgb.b = b;
	return rgb;
}

/**
 * @brief update the color over the given device struct to the provided HEX color
 */
int sk9822_set_color_str(struct sk9822_leds *sk9822, const char *hex)
{
	int i;
	cRGB color = __hexs_to_rgb(hex);

	for (i = 0; i < sk9822->led_count; i++) {
		sk9822->led_colors[i] = color;
	}

	return 0;
}

/**
 * @brief write device struct to the device
 */
int sk9822_update(struct sk9822_leds *sk9822)
{
	uint16_t i;
	uint16_t led_count = sk9822->led_count;

	// Start Frame
	sk9822_bb_write(sk9822, 0x00);
	sk9822_bb_write(sk9822, 0x00);
	sk9822_bb_write(sk9822, 0x00);
	sk9822_bb_write(sk9822, 0x00);

	for (i = 0; i < led_count; i++) {
		cRGB *p = &sk9822->led_colors[i];
		sk9822_bb_write(sk9822, 0xe0+sk9822->led_brightness);  // Maximum global brightness
		sk9822_bb_write(sk9822, p->b);
		sk9822_bb_write(sk9822, p->g);
		sk9822_bb_write(sk9822, p->r);
	}

	// End frame
	sk9822_bb_write(sk9822, 0xff);
	sk9822_bb_write(sk9822, 0xff);
	sk9822_bb_write(sk9822, 0xff);
	sk9822_bb_write(sk9822, 0xff);

	return 0;
}
