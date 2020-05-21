#!/usr/bin/env python3

import json
import re
import sys

from collections import defaultdict


def process_lines(lines, config_map):
    # arch = None
    configs = []
    pkg = None

    arch = list(config_map['_ARCH'])[0]
    os = list(config_map['_OS'])[0]
    platform = list(config_map['_PLATFORM'])[0]
    platform_version = list(config_map['_PLATFORM_VERSION'])[0]
    target = list(config_map['_TARGET'])[0]

    for line in lines:
        # Parse exports
        if line.startswith('export'):
            name, config = line.split('=', 1)
            if 'FLAGS' in name and config.startswith('"'):
                config = config[1:config.rindex('"')]

                # if 'CFLAGS' in name:
                #     arch = re.search(r'-arch (.+?) ', config).groups()[0]

                opts = config.split(' -')
                configs.append(name + ': ' + opts[0])
                for opt in opts[1:]:
                    opt = '-' + opt
                    configs.append(name + ': '+opt)
            else:
                configs.append(name + ': ' + config)

        # Parse ./configure
        if re.match(r'(\.\.\/){1,2}configure', line):
            configs.append(
                'configure: ' + line[line.index('CXX'):line.index('CC')-1])
            configs.append(
                'configure: ' + line[line.index('CC'):line.index(' --host')])

            other_opts = line[line.index('--host'):]
            for opt in other_opts.split(' '):
                configs.append('configure: ' + opt)

        # Get package name
        if line.startswith('mkdir -p {ROOT}'):
            line = line.replace('mkdir -p {ROOT}/', '')
            pkg = line.split('/')[0]

    pkg_os_arch = f'{pkg},{os}_{arch}'

    for config in configs:
        config = config.replace(pkg, '{PKG_NAME}')
        config = config.replace(f'-arch {arch}', '-arch $ARCH')
        config = config.replace(platform, '$PLATFORM')
        config = config.replace(platform_version, '$PLATFORM_VERSION')
        config = config.replace(os, "$PLATFORM_OS")
        config = config.replace(target, '$TARGET')
        config_map[config].add(pkg_os_arch)

    config_map[f'export ARCH: {arch}'].add(pkg_os_arch)
    del(config_map['_ARCH'])

    config_map[f'export PLATFORM: {platform}'].add(pkg_os_arch)
    del(config_map['_PLATFORM'])

    config_map[f'export PLATFORM_OS: {os}'].add(pkg_os_arch)
    del(config_map['_OS'])

    config_map[f'export PLATFORM_VERSION: {platform_version}'].add(pkg_os_arch)
    del(config_map['_PLATFORM_VERSION'])

    config_map[f'export TARGET: {target}'].add(pkg_os_arch)
    del(config_map['_TARGET'])

    return config_map


def extract_vars(line, config_map):
    # ARCH CFLAGS="-arch arm64 -pipe -no-c
    m = re.search(r'-arch (.+?) ', line)
    if m:
        arch = m.group(1)
        config_map['_ARCH'].add(arch)

    # PLATFORM
    # export SDKROOT="{XCODE_DEV}/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.4.sdk"
    # export SDKROOT="{XCODE_DEV}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk"
    m = re.search(r'Platforms/(.+?)"', line)
    if m:
        platform = m.group(1)
        config_map['_PLATFORM'].add(platform)

        if 'iPhone' in platform:
            config_map['_OS'].add('ios')
        else:
            config_map['_OS'].add('macos')

    # PLATFORM_VERSION
    # export CFLAGS="-arch arm64  ... -miphoneos-version-min="11.0"       -O2 -fembed-bitcode"
    # export CFLAGS="-arch x86_64 ... -mios-simulator-version-min="11.0"  -O2 -fembed-bitcode"
    # export CFLAGS="-arch x86_64 ... -mmacosx-version-min="10.13"        -O2 -fembed-bitcode -I{ROOT}/tesseract-4.1.0/macos/x86_64-apple-darwin/ "
    m = re.search(r'(-m.+-min=".+?")', line)
    if m:
        platform_version = m.group(1)
        config_map['_PLATFORM_VERSION'].add(platform_version)

    # TARGET
    m = re.search(r'--target=(.+?)"', line)
    if m:
        target = m.group(1)
        config_map['_TARGET'].add(target)

    return config_map


def parse_make(lines):
    config_map = defaultdict(set)
    _lines = []
    record_lines = False

    for line in lines:
        # if 'usr/bin/make platform=macos' in line:
        #     break

        line = line.strip()
        line = line.replace('; \\', '')
        line = line.replace(
            '/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract', '{ROOT}')
        line = line.replace(
            '/Applications/Xcode.app/Contents/Developer', '{XCODE_DEV}')

        if line.startswith('export LIBS') or line.startswith('export SDKROOT'):
            record_lines = True

        if record_lines:
            _lines.append(line)

        config_map = extract_vars(line, config_map)

        # ./configure is the last line to be recoreded
        if re.match(r'(\.\.\/){1,2}configure', line):
            config_map = process_lines(_lines, config_map)
            _lines = []
            record_lines = False

    for k, v in config_map.items():
        config_map[k] = sorted(list(v))

    return config_map


def main():
    with open('swifty-make-subtractive.txt', 'r') as f:
        config_map = parse_make(f.readlines())
        print(json.dumps(config_map, indent=2))


if __name__ == "__main__":
    main()
