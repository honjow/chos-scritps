#!/usr/bin/python

import subprocess
import evdev
import threading
import os

powerbuttondev = None

devices = [evdev.InputDevice(path) for path in evdev.list_devices()]
for device in devices:
        if device.phys == "PNP0C0C/button/input0":
                powerbuttondev = device;
        else:
                device.close()

longpresstimer = None

def steam_ifrunning_deckui(cmd):
    # Get the currently running Steam PID.
    steampid_path = '/home/gamer/.steam/steam.pid'
    try:
        with open(steampid_path) as f:
            pid = f.read().strip()
    except Exception as err:
        print(f"{err} | Error getting steam PID.")
        return False

    # Get the andline for the Steam process by checking /proc.
    steam_cmd_path = f"/proc/{pid}/cmdline"
    if not os.path.exists(steam_cmd_path):
        # Steam not running.
        return False

    try:
        with open(steam_cmd_path, "rb") as f:
            steam_cmd = f.read()
    except Exception as err:
        print(f"{err} | Error getting steam cmdline.")
        return False 

    # Use this andline to determine if Steam is running in DeckUI mode.
    # e.g. "steam://shortpowerpress" only works in DeckUI.
    is_deckui = b"-gamepadui" in steam_cmd
    if not is_deckui:
        return False

    steam_path = '/home/gamer/.steam/root/ubuntu12_32/steam'
    try:
        result = subprocess.run(["su", "gamer", "-c", f"{steam_path} -ifrunning {cmd}"])
        return result.returncode == 0
    except Exception as err:
        print(f"{err} | Error sending and to Steam.")
        return False

def longpress():
    #os.system( "sudo gamer /home/gamer/.steam/root/ubuntu12_32/steam -ifrunning steam://longpowerpress" )
    is_deckui = steam_ifrunning_deckui("steam://longpowerpress")
    if not is_deckui:
        os.system('systemctl poweroff')
    global longpresstimer
    longpresstimer = None

if powerbuttondev != None:
        for event in powerbuttondev.read_loop():
                if event.type == evdev.ecodes.EV_KEY and event.code == 116: # KEY_POWER
                        print ( f"AAA {event.value}" )
                        if event.value == 1:
                                longpresstimer = threading.Timer( 1.0, longpress )
                                longpresstimer.start()
                        elif event.value == 0:
                                if longpresstimer != None:
                                        #os.system( "sudo gamer /home/gamer/.steam/root/ubuntu12_32/steam -ifrunning steam://shortpowerpress" )
                                        is_deckui = steam_ifrunning_deckui("steam://shortpowerpress")
                                        if not is_deckui:
                                                os.system('systemctl suspend')
                                        longpresstimer.cancel()
                                        longpresstimer = None

        powerbuttondev.close()
        exit()

print ( "power-button-handler.py: Can't find device for power button!" )
