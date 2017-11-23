#!/usr/bin/env python3

"""
//WeekEnd Project
PROJECT: TWITTER #XMAS TREE // with rasberry and python
---------------------
Version 1.1.0 - 2014.12.18

### //Concept IT
Un piccolo script che si mette in ascolto sullo stream di twitter e accende le luci
dell'albero di natale ogni volta che trova una parola specifica (#xmas nel nostro caso)

### //Files:
- code: twitterXmasTree.py
- schema: CircuitoLuci_01.pdf (circuit)

### //This project uses:
** Twython library - https://pypi.python.org/pypi/twython


//Daniele Iori (hold3n)
** www.ibridodesign.com
** daniele.temp@gmail.com

This work is licensed under a Creative Commons Attribution 3.0 - http://creativecommons.org/licenses/by/3.0/
"""

__author__ = 'daniele'

from twython import Twython, TwythonStreamer, TwythonError
import RPi.GPIO as gpio
import time

# SETUP TWYTHON
TWITTER_APP_KEY = 'insert key'
TWITTER_APP_KEY_SECRET = 'insert key'
TWITTER_ACCESS_TOKEN = 'insert key'
TWITTER_ACCESS_TOKEN_SECRET = 'insert key'

# TERMINI DI RICERCA
terminericerca = '#xmas, #merrychristmas'

# FILE IN CUI SALVA I TWEET
nomefile = "/tweetdump.txt"

# PULSAZIONE DI ERRORE
pulsazione = float(1)
errore = pulsazione/3

# SETUP GPIO
gpio.setmode(gpio.BOARD)
gpio_luci=13

gpio.setup(gpio_luci, gpio.OUT)

class MyStreamer(TwythonStreamer):
    #SEARCH FOR HASHTAG AND POST TWEETS
    counter = 0

    def on_success(self, data):
        if 'text' in data:
            self.counter += 1

            # Estrae i dati da oggetto e Salva in un file
            TEXT = str(data['text'].encode('utf-8'))
            USER = str(data['user']['name'].encode('utf-8'))
            MSG = str(self.counter) + "| " + USER + ": " + TEXT + '\n\n'
            print(MSG)
            with open(nomefile, 'a') as f:
                f.writelines(MSG)


        # PULSAZIONE LUCI STANDARD
            #1
            gpio.output(gpio_luci, True) #accendi
            time.sleep(pulsazione*2)
            gpio.output(gpio_luci, False) #spegni
            time.sleep(pulsazione)
            #2
            gpio.output(gpio_luci, True) #accendi
            time.sleep(pulsazione/2)
            gpio.output(gpio_luci, False) #spegni
            time.sleep(pulsazione/2)
            #3
            gpio.output(gpio_luci, True) #accendi
            time.sleep(pulsazione/2)
            gpio.output(gpio_luci, False) #spegni
            time.sleep(pulsazione/2)
            #4
            gpio.output(gpio_luci, True) #accendi
            time.sleep(pulsazione/2)
            gpio.output(gpio_luci, False) #spegni
            time.sleep(pulsazione/2)
            #5
            gpio.output(gpio_luci, True) #accendi
            time.sleep(pulsazione*2)
            gpio.output(gpio_luci, False) #spegni
            time.sleep(pulsazione/2)

            return

    def on_error(self, status_code, data):
        gpio.output(gpio_luci, True) #accendi
        time.sleep(errore)
        gpio.output(gpio_luci, False) #spegni
        time.sleep(errore)
        print(status_code)


# SEGNALE INIZIALIZZAZIONE
gpio.output(gpio_luci, True) #accendi
time.sleep(3)
gpio.output(gpio_luci, False) #spegni
time.sleep(pulsazione)


# STAMPA INTESTAZONE FILE
Chiave = "Chiave: " + terminericerca + '\n'
Giorno = str(time.strftime("%d/%m/%Y")) + " " + str(time.strftime("%H:%M:%S")) + '\n'
Barra = "-"*20 + '\n'

INTESTAZIONE = '\n' + Chiave + Giorno + Barra
print(INTESTAZIONE)
with open(nomefile, 'a') as f:
                f.writelines(INTESTAZIONE)


# debug
print(nomefile)

#READ TWITTER STREAM
stream = MyStreamer(TWITTER_APP_KEY, TWITTER_APP_KEY_SECRET,TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
stream.statuses.filter(track=terminericerca)