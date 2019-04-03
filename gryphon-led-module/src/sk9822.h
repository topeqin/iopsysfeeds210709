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

#ifndef SK9822_H_
#define SK9822_H_

#include <linux/types.h>

#define SK9822_DEFAULT_NUM_LEDS 32 // U16, used if DT param fails
#define SK9822_DEFAULT_BRIGHTNESS 31  // 5-bit brightness, 0-31

typedef struct {
	uint8_t b;
	uint8_t g;
	uint8_t r;
} cRGB;   // BGR (SK9822 Standard)

struct sk9822_leds {
	struct device *dev;
	struct gpio_desc *clock_gpio;
	struct gpio_desc *data_gpio;

	cRGB *led_colors;
	uint8_t led_brightness;
	uint16_t led_count;
};

int sk9822_set_color_str(struct sk9822_leds *sk9822, const char *hex);
int sk9822_update(struct sk9822_leds *sk9822);

#endif /* SK9822_H_ */
