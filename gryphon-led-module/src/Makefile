# Copyright (c) 2017 Genexis B.V.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA

MODULE_NAME  = gryphon-led-kernel-module

obj-m  := $(MODULE_NAME).o

GENEXIS_FILES= \
	main.o \
	sk9822.o \
	sk9822_bitbang.o

$(MODULE_NAME)-objs := $(GENEXIS_FILES)
