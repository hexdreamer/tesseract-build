#!/usr/bin/env python3

import re

fnames_and_libs = [
  # ('leptonica', 'liblept', '6'),
  # ('libtiff', 'libtiff', '5'),
  # ('libjpeg', 'libjpeg', '5'),
  # ('libpng', 'libpng16', '5'),
  ('tesseract', 'libtesseract', '6')
]

for fname, libname, lipo_step in fnames_and_libs:
  build_script = f'build_{fname}.sh'
  with open(build_script) as f:
    text = f.read()

    ## -- BUILD CONFIGS -------------------------------------------------------

    # Get current iOS configuration
    current_ios_arm64 = f"""# ios_arm64
export ARCH='arm64'
export TARGET='arm-apple-darwin64'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

zsh $parentdir/config-make-install_{fname}.sh $name 'ios_arm64' || exit 1"""

    # Transform to new iOS arm64 target
    updated_ios_arm64 = current_ios_arm64.replace('arm-apple-darwin64', 'arm64-apple-ios14.3')
    updated_ios_arm64 = updated_ios_arm64.replace('11.0', '14.3')

    # Transform to new iOS arm64 Simulator target
    new_ios_arm64_sim = updated_ios_arm64.replace('arm64-apple-ios14.3', 'arm64-apple-ios14.3-simulator')
    new_ios_arm64_sim = new_ios_arm64_sim.replace('iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk', 'iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk')
    new_ios_arm64_sim = new_ios_arm64_sim.replace('ios_arm64', 'ios_arm64_sim')

    # Update current iOS x86 Simulator configuration to new min-version 14.3
    current_ios_x86_64_sim = f"""# ios_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-ios14.3-simulator'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=11.0'

zsh $parentdir/config-make-install_{fname}.sh $name 'ios_x86_64' || exit 1"""

    updated_ios_x86_64_sim = current_ios_x86_64_sim.replace('11.0', '14.3')
    updated_ios_x86_64_sim = updated_ios_x86_64_sim.replace('ios_x86_64', 'ios_x86_64_sim')

    # Get current macOS x86 configuration
    current_macos_x86_64 = f"""# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-ios14.3-simulator'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_{fname}.sh $name 'macos_x86_64' || exit 1"""

    # Update current configuration to new target name
    updated_macos_x86_64 = current_macos_x86_64.replace('x86_64-apple-ios14.3-simulator', 'x86_64-apple-macos10.13')

    # Transform to new macOS arm64 target
    new_macos_arm64 = current_macos_x86_64.replace('x86_64-apple-ios14.3-simulator', 'arm64-apple-macos11.0')
    new_macos_arm64 = new_macos_arm64.replace('x86_64', 'arm64')
    new_macos_arm64 = new_macos_arm64.replace('10.13', '11.0')

    # Replace
    assert current_ios_arm64 in text, current_ios_arm64
    text = text.replace(current_ios_arm64, updated_ios_arm64 + '\n\n' + new_ios_arm64_sim)

    assert current_ios_x86_64_sim in text, current_ios_x86_64_sim
    text = text.replace(current_ios_x86_64_sim, updated_ios_x86_64_sim)

    assert current_macos_x86_64 in text, current_macos_x86_64
    text = text.replace(current_macos_x86_64, updated_macos_x86_64 + '\n\n' + new_macos_arm64)

    ## -- LIPO ----------------------------------------------------------------
    current_lipo = f"""
print -n 'lipo: ios... '
xl $name '{lipo_step}_ios_lipo' \\
  xcrun lipo $ROOT/ios_arm64/lib/{libname}.a $ROOT/ios_x86_64/lib/{libname}.a \\
  -create -output $ROOT/lib/{libname}.a ||
  exit 1
print 'done.'

print -n 'lipo: macos... '
xl $name '{lipo_step}_macos_lipo' \\
  xcrun lipo $ROOT/macos_x86_64/lib/{libname}.a \\
  -create -output $ROOT/lib/{libname}-macos.a ||
  exit 1
print 'done.'
"""

    new_lipo = f"""
print -n 'lipo: ios... '
xl $name '{lipo_step}_ios_lipo' \\
  xcrun lipo $ROOT/ios_arm64/lib/{libname}.a \\
  -create -output $ROOT/lib/{libname}-ios.a ||
  exit 1
print 'done.'

print -n 'lipo: sim... '
xl $name '{lipo_step}_sim_lipo' \\
  xcrun lipo $ROOT/ios_arm64_sim/lib/{libname}.a $ROOT/ios_x86_64_sim/lib/{libname}.a \\
  -create -output $ROOT/lib/{libname}-sim.a ||
  exit 1
print 'done.'

print -n 'lipo: macos... '
xl $name '{lipo_step}_macos_lipo' \\
  xcrun lipo $ROOT/macos_x86_64/lib/{libname}.a $ROOT/macos_arm64/lib/{libname}.a \\
  -create -output $ROOT/lib/{libname}-macos.a ||
  exit 1
print 'done.'
"""

    # Replace
    assert current_lipo in text, current_lipo
    text = text.replace(current_lipo, new_lipo)

  # Save new configs
  with open(build_script, 'w') as f:
      f.write(text)
