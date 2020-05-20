#!/usr/bin/env python3

import sys
import json
from collections import defaultdict

config_map = defaultdict(set)
_configs = []
pkg = None
platform = None
scan_for_pkg = False
target = None

with open('make.log', 'r') as f:
    for line in f:
        line = line.replace('; \\', '')
        line = line.replace(
            '/Users/zyoung/dev/SwiftyTesseract/SwiftyTesseract/SwiftyTesseract', '{ROOT}')
        line = line.replace(
            '/Applications/Xcode.app/Contents/Developer', '{XCODE_DEV}')
        line = line.strip()

        if line.contains('usr/bin/make platform='):
            platform = line.split('=')[1]

        if line.startswith('curl'):
            if pkg:
                for config in _configs:
                    config = config.replace(pkg, '{PKG_NAME}')
                    config_map[config].add(pkg)
                pkg = None
                _configs = []

            scan_for_pkg = True

        if line.startswith('export'):
            name, config = line.split('=', 1)
            if 'FLAGS' in name and config.startswith('"'):
                try:
                    config=config[1:config.rindex('"')]
                except:
                    print(line)
                    sys.exit(1)
                opts = config.split(' -')
                _configs.append(name + ': ' + opts[0])
                for opt in opts[1:]:
                    _configs.append(name + ': -' + opt)
            else:
                _configs.append(name + ': ' + config)

        if '../configure' in line:
            # "../configure CXX=\"\"\"`xcode-select -p`\"/usr/bin/g++\" --target=x86_64-apple-darwin\" CC=\"\"\"`xcode-select -p`\"/usr/bin/gcc\" --target=x86_64-apple-darwin\" --host=x86_64-apple-darwin --enable-shared=no --prefix=`pwd`":
            # [
            #     "libpng-1.6.36",
            #     "jpeg-9c"
            # ],
            _configs.append(
                'configure: ' + line[line.index('CXX'):line.index('CC')-1])
            _configs.append(
                'configure: ' + line[line.index('CC'):line.index(' --host')-1])

            other_opts = line[line.index('--host'):]
            for opt in other_opts.split(' '):
                _configs.append('configure: ' + opt)

        if scan_for_pkg and line.startswith('mkdir -p {ROOT}'):
            # mkdir -p {ROOT}/jpeg-9c/arm-apple-darwin64
            # extract jpeg-9c
            line = line.replace('mkdir -p {ROOT}/', '')
            pkg = line.split('/')[0]
            # print(pkg)
            scan_for_pkg = False

for config in _configs:
    config = config.replace(pkg, '{PKG_NAME}')
    config_map[config].add(pkg)

for k, v in config_map.items():
    config_map[k] = sorted(list(v))

# with open('configs.json', 'w') as f:
#     f.write(json.dumps(config_map, indent=2))
print(json.dumps(config_map, indent=2))
