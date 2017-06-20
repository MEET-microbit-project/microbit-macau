import random
import os

from microbit import *

if 'messages.txt' in os.listdir():

    with open('messages.txt') as message_file:
        messages = message_file.read().split('\n')

    while True:
        if button_a.was_pressed():
            display.scroll(random.choice(messages))
