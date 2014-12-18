"""
//WeekEnd Project
PROJECT: TWITTER #XMAS TREE // with rasberry and python
---------------------
Version 1.0.0 - 2014.12.18

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

from twython import Twython, TwythonStreamer, TwythonError
import RPi.GPIO as gpio
import time

# SETUP TWYTHON
TWITTER_APP_KEY = ' insert your key '
TWITTER_APP_KEY_SECRET = ' insert your key '
TWITTER_ACCESS_TOKEN = ' insert your key '
TWITTER_ACCESS_TOKEN_SECRET = ' insert your key '

# SETUP ALBERO
terminericerca = '#xmas'    #chiave
pulsazione = float(1)       #tempo di pulsazione
errore = pulsazione/3       #pulsazione rapida per segnalazione errori

# SETUP GPIO
gpio.setmode(gpio.BOARD)
gpio_luci=7

gpio.setup(gpio_luci, gpio.OUT)

class MyStreamer(TwythonStreamer):
    #SEARCH FOR HASHTAG AND POST TWEETS

    def on_success(self, data):
        if 'text' in data:
            print("ok ")
            gpio.output(gpio_luci, True) #accendi
            time.sleep(pulsazione)
            gpio.output(gpio_luci, False) #spegni
            time.sleep(pulsazione)
            return

    def on_error(self, status_code, data):
        gpio.output(gpio_luci, True) #accendi
        time.sleep(errore)
        gpio.output(gpio_luci, False) #spegni
        time.sleep(errore)
        print(status_code)

#READ TWITTER STREAM
stream = MyStreamer(TWITTER_APP_KEY, TWITTER_APP_KEY_SECRET,TWITTER_ACCESS_TOKEN, TWITTER_ACCESS_TOKEN_SECRET)
stream.statuses.filter(track=terminericerca)



