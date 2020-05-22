#!/usr/bin/env python3

import json
import sys

from collections import defaultdict
from io import StringIO


def build_config_func(name, configs, call_common, call_common_all):
    s = StringIO()

    _configs = defaultdict(list)
    for config in configs:
        k, v = config.split(': ')
        _configs[k].append(v)

    s.write('%s() {\n' % name)
    for k, vs in sorted(_configs.items()):
        # special sort for ./configure to put CC and CCX before --flags
        vs = sorted(vs, key=lambda x: (x.startswith('-'), x.lower()))

        if len(vs) == 1:
            s.write("%s=%s\n" % (k, vs[0]))
        else:
            s.write('%s=(\n' % k)
            for v in vs:
                if v.startswith('-'):
                    s.write("'%s'\n" % v)
                else:
                    s.write('%s\n' % v)
            s.write(')\n')

    if call_common:
        s.write('\ncommon\n')

    if call_common_all:
        s.write('\ncommon_all\n')

    s.write('}\n')

    return s.getvalue()


def transform(config_pkgarches_map):
    # Iterate all configs and "bin" by pkg-arch name
    _pkgs_configs = defaultdict(set)
    for config, pkgarches in config_pkgarches_map.items():
        for pkgarch in pkgarches:
            _pkgs_configs[pkgarch].add(config)

    # Configs common across ALL bins
    all_configs = list(_pkgs_configs.values())
    common_all = all_configs[0].intersection(*all_configs[1:])

    # Create new hierarchy; invert:
    #   {config1: [pkg1_arch1, pkg1_arch2], config2: [pkg1_arch1]}
    #   to...
    #   {pkg1: {arch1: [config1, config2], arch2: [config1]}}
    pkgs_configs = {}
    for config, pkgarches in config_pkgarches_map.items():
        for pkgarch in pkgarches:
            pkg, arch = pkgarch.split(',')

            if pkg not in pkgs_configs:
                pkgs_configs[pkg] = {}

            if arch not in pkgs_configs[pkg]:
                pkgs_configs[pkg][arch] = set()

            pkgs_configs[pkg][arch].add(config)

    # Process hierarchy, extracting common configs
    for pkg, arches_configs in pkgs_configs.items():
        arches = arches_configs.keys()
        configs = list(arches_configs.values())
        common_arches = configs[0].intersection(*configs[1:]) - common_all
        for arch in arches:
            pkgs_configs[pkg][arch] = sorted(list(
                pkgs_configs[pkg][arch]-common_arches-common_all))
        if common_arches:
            pkgs_configs[pkg]['common'] = sorted(list(common_arches))

    if common_all:
        pkgs_configs['common'] = {'common': sorted(list(common_all))}

    return pkgs_configs


def main():
    with open('../configs.json', 'r') as f:
        config_arch_map = json.loads(f.read())

    pkg_arches_configs = transform(config_arch_map)

    pkgs=list(pkg_arches_configs.keys())

    call_common_all=False
    if 'common' in pkgs:
        call_common_all=True
        with open('common.sh', 'w') as f:
            f.write('#!/bin/zsh -f\n')
            f.write(build_config_func('common_all', pkg_arches_configs['common']['common'], False, False))
        pkgs.remove('common')
    
    for pkg in pkgs:
        arches_configs = pkg_arches_configs[pkg]
        arches = list(arches_configs.keys())

        with open(pkg+'.sh', 'w') as f:
            f.write('#!/bin/zsh -f\n')
            call_common=False
            if 'common' in arches:
                call_common=True
                f.write(build_config_func('common', arches_configs['common'], False, call_common_all))
                arches.remove('common')                

            for arch in arches:
                configs = arches_configs[arch]
                f.write(build_config_func(arch, configs, call_common, False))


if __name__ == "__main__":
    main()
