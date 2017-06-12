from microbit import *

count = 0

while True:
    count = count + button_b.get_presses() - button_a.get_presses()
    sleep(200)
    display.scroll(str(count))
