#!/usr/bin/env python3
"""Verify the final AAOS manifest; optionally smoke-test a dedicated API 35 AAOS AVD."""

import argparse
from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET


A = '{http://schemas.android.com/apk/res/android}'
PACKAGE = 'com.hermesagent.hermes_android.automotive.preview'
ACTIVITY = 'com.hermesagent.hermes_android.MainActivity'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def check_manifest(root):
    require(root.get('package') == PACKAGE, 'not the private Automotive preview package')
    car = root.find(f"uses-feature[@{A}name='android.hardware.type.automotive']")
    require(car is not None and car.get(A + 'required') == 'true', 'AAOS must be required')
    for elt in root.iter():
        name = elt.get(A + 'name', '')
        require(name not in {
            'android.permission.RECORD_AUDIO', 'android.permission.POST_NOTIFICATIONS',
            'android.permission.REQUEST_INSTALL_PACKAGES', 'com.google.android.gms.car.application',
            'com.google.android.gms.car.notification.SmallIcon', 'distractionOptimized',
            'android.intent.category.CAR_LAUNCHER', 'androidx.car.app.CarAppService',
        }, f'unexpected manifest entry: {name}')
        require(not name.endswith('.AutoMessageReceiver'), 'phone reply receiver present')
        require(elt.get(A + 'authorities') != PACKAGE + '.update_provider', 'APK updater present')
    activity = root.find(f"./application/activity[@{A}name='{ACTIVITY}']")
    if activity is None or activity.get(A + 'exported') != 'true':
        raise ValueError('no Ares activity')
    require(any(f.find(f"action[@{A}name='android.intent.action.MAIN']") is not None
                and f.find(f"category[@{A}name='android.intent.category.LAUNCHER']") is not None
                for f in activity.findall('intent-filter')), 'no ordinary AAOS launcher')


def run(*args):
    return subprocess.check_output(args, text=True, timeout=45).strip()


def until(description, predicate):
    end = time.monotonic() + 20
    while time.monotonic() < end:
        if predicate():
            print('PASS:', description, flush=True)
            return
        time.sleep(.4)
    raise RuntimeError('timed out: ' + description)


def smoke(serial, adb):
    require(re.fullmatch(r'emulator-\d+', serial), 'only use a dedicated AAOS emulator')

    def shell(*args):
        return run(adb, '-s', serial, 'shell', *args)

    def restrictions():
        return shell('cmd', 'car_service', 'get-current-ux-restrictions')

    def driver_activities():
        dump = shell('dumpsys', 'activity', 'activities')
        section = re.search(r'^Display #0 .*?\n(.*?)(?=^Display #|\Z)', dump, re.M | re.S)
        if section is None:
            raise ValueError('driver display not found')
        return '\n'.join(line for line in section[1].splitlines() if 'topResumedActivity=' in line)

    def launch():
        shell('am', 'start', '--user', 'current', '-a', 'android.intent.action.MAIN',
              '-c', 'android.intent.category.LAUNCHER', '-n', PACKAGE + '/' + ACTIVITY)

    def blocked():
        resumed = driver_activities()
        return 'BlockingActivity' in resumed and PACKAGE not in resumed

    require(shell('getprop', 'ro.kernel.qemu') == '1', 'not an emulator')
    require('feature:android.hardware.type.automotive' in shell('pm', 'list', 'features').splitlines(),
            'not Automotive OS')
    require('package:' in shell('pm', 'path', '--user', 'current', PACKAGE), 'install the APK first')
    require('baseline' in restrictions(), 'start the test parked')
    launch()
    until('Ares resumed on the parked driver display', lambda: PACKAGE in driver_activities())
    try:
        shell('cmd', 'car_service', 'emulate-driving-state', 'drive')
        until('driver display restricts text', lambda: 'no_text_message' in restrictions())
        until('OS covers the already-open app', blocked)
        launch()
        until('launch remains blocked while driving', blocked)
    finally:
        shell('cmd', 'car_service', 'emulate-driving-state', 'park')
        until('park restored', lambda: 'baseline' in restrictions())
    launch()
    until('Ares resumed again after parking', lambda: PACKAGE in driver_activities())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('manifest', type=Path, help='XML from apkanalyzer manifest print <apk>')
    parser.add_argument('--emulator', help='opt in to the driving-state test on this AVD')
    parser.add_argument('--adb', default='adb')
    args = parser.parse_args()
    check_manifest(ET.parse(args.manifest).getroot())
    print('PASS: parked Automotive manifest', flush=True)
    if args.emulator:
        smoke(args.emulator, args.adb)


if __name__ == '__main__':
    main()
