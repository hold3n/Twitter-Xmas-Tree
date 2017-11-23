#!/usr/bin/env python3

# utility script per resettare i pin di raspberry


import RPi.GPIO as gpio

# SETUP GPIO
gpio.setmode(gpio.BOARD)
gpio_luci=13
gpio.setup(gpio_luci, gpio.OUT)

gpio.cleanup()

print("canale:" + str(gpio_luci) + " inizializzato")
