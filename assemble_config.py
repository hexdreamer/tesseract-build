#!/usr/bin/env python3

import json
import sys

from collections import defaultdict

with open('configs.json', 'r') as f:
    config_map = json.loads(f.read())

configs = []
pkg = sys.argv[1]
arch = sys.argv[2]

configs = defaultdict(list)
for config, pkgs_arches in config_map.items():
    for pkg_arch in pkgs_arches:
        if pkg_arch == f'{pkg},{arch}':
            k, v = config.split(': ')
            configs[k].append(v)

for k, vs in sorted(configs.items()):
    # special sort for ./configure to put CC and CCX before --flags
    vs = sorted(vs, key=lambda x: (x.startswith('-'), x.lower()))

    print('%s=(' % k )
    for v in vs:
        if v.startswith('-'):
            print("'%s'" % v)
        else:
            print(v)
    print(')')

