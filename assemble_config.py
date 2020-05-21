#!/usr/bin/env python3

import json
import sys

from collections import defaultdict

with open('configs.json', 'r') as f:
    config_arch_map = json.loads(f.read())

pkg = sys.argv[1]

arch_config_map = defaultdict(set)
for config, pkgs_arches in config_arch_map.items():
    for pkg_arch in pkgs_arches:
        if pkg in pkg_arch:
            arch = pkg_arch.split(',')[1]
            arch_config_map[arch].add(config)

arches = list(arch_config_map.keys())
configs = list(arch_config_map.values())

common = configs[0].intersection(*configs[1:])
for i in range(len(configs)):
    configs[i] = configs[i] - common

print('#!/bin/zsh -f')
for name, configs in [('common', common)] + list(zip(arches, configs)):
    print('%s() {' % name)

    _configs = defaultdict(list)
    for config in configs:
        k,v = config.split(': ')
        _configs[k].append(v)
    
    for k, vs in sorted(_configs.items()):
        # special sort for ./configure to put CC and CCX before --flags
        vs = sorted(vs, key=lambda x: (x.startswith('-'), x.lower()))

        if len(vs) == 1:
            print("%s=%s" % (k, vs[0]) )
        else:
            print('%s=(' % k )
            for v in vs:
                if v.startswith('-'):
                    print("'%s'" % v)
                else:
                    print(v)
            print(')')

    print('}')