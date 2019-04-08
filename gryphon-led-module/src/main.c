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

#define DEBUG 1

#include <linux/delay.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/printk.h>
#include <linux/init.h>
#include <linux/err.h>
#include <linux/platform_device.h>
#include <linux/gpio/consumer.h>
#include <linux/of.h>
#include <linux/version.h>

#include "sk9822.h"

#define DRIVER_NAME			"canyon_led"
#define DRIVER_AUTHOR		"Genexis B.V."
#define DRIVER_DESC			"Canyon LED driver for SK9822"
#define DRIVER_VERSION	"1"

/**
 * sysfs interfaces
 */

static ssize_t get_led_color(struct device *dev,
		struct device_attribute *attr, char *buf)
{
	/* [ln] todo: dummy implementation */
	int len;

	len = sprintf(buf, "%d\n", 123);
	if (len <= 0) {
		dev_err(dev, "sk9822: Invalid sprintf len: %d\n", len);
	}

	return len;
}

/**
 * @brief Set complete LED strip to a specific color
 * @retval count number of bytes written
 * @retval -EMSGSIZE if the message is too big
 * @retval -EIO for all other errors (e.g. leds cannot be configured)
 */
static ssize_t set_led_color(struct device *dev,
		struct device_attribute *attr, const char *buf, size_t count)
{
	int ret = 0;
	size_t buflen = count;
	struct sk9822_leds *sk9822 = dev_get_drvdata(dev);

	if (IS_ERR(sk9822)) {
		printk(KERN_ERR "Platform get drvdata returned NULL\n");
		return -EIO;
	}

	/* strip newline */
	if ((count > 0) && (buf[count-1] == '\n')) {
		buflen--;
	}

	if (buflen != 6) { // RRGGBB\0
		return -EMSGSIZE;
	}

	// Update the LED array here
	ret = sk9822_set_color_str(sk9822, buf);
	if (ret != 0) {
		printk(KERN_ERR "Failed to set led color\n");
		return -EIO;
	}

	// Now push to the HW
	ret = sk9822_update(sk9822);
	if (ret != 0) {
		printk(KERN_ERR "Failed to update led\n");
		return -EIO;
	}

	return count;
}
static DEVICE_ATTR(led_color, S_IRUGO | S_IWUSR, get_led_color, set_led_color);

static struct attribute *sk9822_dev_attrs[] = {
	 &dev_attr_led_color.attr,
	 NULL
};

static struct attribute_group sk9822_dev_attr_group = {
	.name = "sk9822",
	.attrs = sk9822_dev_attrs,
};

/**
 * device prope and removal
 */

static int canyon_led_probe(struct platform_device *pdev)
{
	int ret;
	struct sk9822_leds *leds;

	leds = devm_kzalloc(&pdev->dev, sizeof(*leds), GFP_KERNEL);
	if (!leds) {
		return -ENOMEM;
	}
	leds->dev = &pdev->dev;
	leds->led_brightness = SK9822_DEFAULT_BRIGHTNESS;

	ret = of_property_read_u16(pdev->dev.of_node, "led-count", &leds->led_count);
	if (ret < 0) {
		dev_warn(&pdev->dev, "Could not read led-count property\n");
		leds->led_count = SK9822_DEFAULT_NUM_LEDS;
	}

	leds->led_colors = devm_kzalloc(&pdev->dev,
			(sizeof(cRGB) * leds->led_count), GFP_KERNEL);
	if (!leds->led_colors) {
		return -ENOMEM;
	}


	platform_set_drvdata(pdev, leds);

#if LINUX_VERSION_CODE <= KERNEL_VERSION(3, 16, 0)
	leds->clock_gpio = gpiod_get_index(&pdev->dev, "led", 0);
#elif LINUX_VERSION_CODE >= KERNEL_VERSION(4, 3, 0)
	leds->clock_gpio = gpiod_get_index(&pdev->dev, "led", 0, GPIOD_OUT_HIGH);
#else
	dev_warn(&pdev->dev, "Kernel version Not supported\n");
	exit(1);
#endif

	gpiod_direction_output(leds->clock_gpio, 1);
	if (IS_ERR(leds->clock_gpio)) {
		dev_err(&pdev->dev, "Failed to acquire clock GPIO %ld\n",
				PTR_ERR(leds->clock_gpio));
		leds->clock_gpio = NULL;
		return PTR_ERR(leds->clock_gpio);
	} else {
		printk(KERN_INFO "Got clock gpio\n");
		gpiod_set_value(leds->clock_gpio, 0);
	}

#if LINUX_VERSION_CODE <= KERNEL_VERSION(3, 16, 0)
	leds->data_gpio = gpiod_get_index(&pdev->dev, "led", 1);
#elif LINUX_VERSION_CODE >= KERNEL_VERSION(4, 3, 0)
	leds->data_gpio = gpiod_get_index(&pdev->dev, "led", 1, GPIOD_OUT_HIGH);
#else
	dev_warn(&pdev->dev, "Kernel version Not supported\n");
	exit(1);
#endif

	gpiod_direction_output(leds->data_gpio, 1);
	if (IS_ERR(leds->data_gpio)) {
		dev_err(&pdev->dev, "Failed to acquire data GPIO %ld\n",
				PTR_ERR(leds->data_gpio));
		leds->data_gpio = NULL;
		return PTR_ERR(leds->data_gpio);
	} else {
		printk(KERN_INFO "Got data gpio\n");
		gpiod_set_value(leds->data_gpio, 0);
	}

	printk(KERN_INFO "Attempt to set filefs stuff\n");
	ret = sysfs_create_group(&pdev->dev.kobj, &sk9822_dev_attr_group);
	if (ret) {
		dev_err(&pdev->dev, "sysfs creation failed\n");
		return ret;
	}

#if 0
	printk(KERN_INFO "Flash LEDs to verify they work\n");
	sk9822_set_color_str(leds, "00FF00");
	sk9822_update(leds);
	msleep(200);
#endif
	sk9822_set_color_str(leds, "000000");
	sk9822_update(leds);

	printk(KERN_INFO "canyon led successfully probed\n");

	return 0;
}

static int canyon_led_remove(struct platform_device *pdev)
{
	struct sk9822_leds *leds;

	sysfs_remove_group(&pdev->dev.kobj, &sk9822_dev_attr_group);

	leds = platform_get_drvdata(pdev);
	if (IS_ERR(leds)) {
		printk(KERN_ERR "Platform get drvdata returned NULL\n");
		return -1;
	}

	if (leds->clock_gpio) {
		gpiod_put(leds->clock_gpio);
	}

	if (leds->data_gpio) {
		gpiod_put(leds->data_gpio);
	}

	printk(KERN_NOTICE "Bye, bye\n");

	return 0;
}

/**
 * platform driver metadata
 */

static const struct of_device_id canyon_led_of_ids[] = {
	{ .compatible = "canyon,led" },
	{ }
};

static struct platform_driver canyon_led = {
	.probe = &canyon_led_probe,
	.remove = &canyon_led_remove,
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table = canyon_led_of_ids,
	},
};

MODULE_DEVICE_TABLE(of, canyon_led_of_ids);
module_platform_driver(canyon_led);
MODULE_AUTHOR(DRIVER_AUTHOR);
MODULE_DESCRIPTION(DRIVER_DESC);
MODULE_VERSION(DRIVER_VERSION);
MODULE_LICENSE("GPL");
