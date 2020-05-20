#!/usr/bin/env python3

import json
import re
import sys

from collections import defaultdict


def process_lines(lines, config_map):
    arch = None
    configs = []
    pkg = None
    for line in lines:
        # Parse exports
        if line.startswith('export'):
            name, config = line.split('=', 1)
            if 'FLAGS' in name and config.startswith('"'):
                config = config[1:config.rindex('"')]

                if 'CFLAGS' in name:
                    arch = re.search(r'-arch (.+?) ', config).groups()[0]

                opts = config.split(' -')
                configs.append(name + ': ' + opts[0])
                for opt in opts[1:]:
                    configs.append(name + ': -' + opt)
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

    for config in configs:
        config = config.replace(pkg, '{PKG_NAME}')
        config_map[config].add(f'{pkg},{arch}')

    return config_map


config_map = defaultdict(set)
lines = []
record_lines=False

with open('make.log', 'r') as f:
    for line in f:
        if 'usr/bin/make platform=macos' in line:
            break

        line = line.strip()
        line = line.replace('; \\', '')
        line = line.replace(
            '/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract', '{ROOT}')
        line = line.replace(
            '/Applications/Xcode.app/Contents/Developer', '{XCODE_DEV}')

        if line.startswith('export SDKROOT'):
            record_lines = True

        if record_lines:
            lines.append(line)

        if re.match(r'(\.\.\/){1,2}configure', line):
            config_map = process_lines(lines, config_map)
            lines=[]
            record_lines = False


for k, v in config_map.items():
    config_map[k] = sorted(list(v))

# with open('configs.json', 'w') as f:
#     f.write(json.dumps(config_map, indent=2))
print(json.dumps(config_map, indent=2))
