#!/usr/bin/env python3

__author__ = 'daniele'

import RPi.GPIO as gpio
import time


# PULSAZIONE
pulsazione = float(1)
errore = pulsazione/3

# SETUP GPIO
gpio.setmode(gpio.BOARD)
gpio_luci=13

gpio.setup(gpio_luci, gpio.OUT)




# SEGNALE INIZIALIZZAZIONE
def pulsa():
    gpio.output(gpio_luci, True) #accendi
    time.sleep(errore)
    gpio.output(gpio_luci, False) #spegni
    time.sleep(errore)


while True:
    pulsa()
    print("ok")





