#!/usr/bin/env python3



# Get current iOS configuration
current_ios_arm64 = """# ios_arm64
export ARCH='arm64'
export TARGET='arm-apple-darwin64'
export PLATFORM='iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk'
export PLATFORM_MIN_VERSION='-miphoneos-version-min=11.0'

zsh $parentdir/config-make-install_libjpeg.sh $name 'ios_arm64' $dirname || exit 1"""

# Transform to new iOS arm64 target
updated_ios_arm64 = current_ios_arm64.replace('arm-apple-darwin64', 'arm64-apple-ios14.3')
updated_ios_arm64 = updated_ios_arm64.replace('11.0', '14.3')

# Transform to new iOS arm64 Simulator target
new_ios_arm64_sim = updated_ios_arm64.replace('arm64-apple-ios14.3', 'arm64-apple-ios14.3-simulator')
new_ios_arm64_sim = new_ios_arm64_sim.replace('iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk', 'iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk')
new_ios_arm64_sim = new_ios_arm64_sim.replace('ios_arm64', 'ios_arm64_sim')

# Update current iOS x86 Simulator configuration to new min-version 14.3
current_ios_x86_64_sim = """# ios_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk'
export PLATFORM_MIN_VERSION='-mios-simulator-version-min=11.0'

zsh $parentdir/config-make-install_libjpeg.sh $name 'ios_x86_64' $dirname || exit 1"""

updated_ios_x86_64_sim = current_ios_x86_64_sim.replace('11.0', '14.3')
updated_ios_x86_64_sim = updated_ios_x86_64_sim.replace('ios_x86_64', 'ios_x86_64_sim')

# Get current macOS x86 configuration
current_macos_x86_64 = """# macos_x86_64
export ARCH='x86_64'
export TARGET='x86_64-apple-darwin'
export PLATFORM='MacOSX.platform/Developer/SDKs/MacOSX.sdk'
export PLATFORM_MIN_VERSION='-mmacosx-version-min=10.13'

zsh $parentdir/config-make-install_libjpeg.sh $name 'macos_x86_64' $dirname || exit 1"""

# Update current configuration to new target name
updated_macos_x86_64 = current_macos_x86_64.replace('x86_64-apple-darwin', 'x86_64-apple-macos10.13')

# Transform to new macOS arm64 target
new_macos_arm64 = current_macos_x86_64.replace('x86_64-apple-darwin', 'arm64-apple-macos11.0')
new_macos_arm64 = new_macos_arm64.replace('x86_64', 'arm64')
new_macos_arm64 = new_macos_arm64.replace('10.13', '11.0')

# print(updated_ios_arm64 + '\n')
# print(new_ios_arm64_sim + '\n')
# print(updated_ios_x86_64_sim + '\n')
# print(new_macos_arm64 + '\n')
# print(updated_macos_x86_64 + '\n')

with open('build_libjpeg.sh') as f:
    text = f.read()

    text = text.replace(current_ios_arm64, updated_ios_arm64 + '\n\n' + new_ios_arm64_sim + '\n')

    text = text.replace(current_ios_x86_64_sim, updated_ios_x86_64_sim)

    text = text.replace(current_macos_x86_64, updated_macos_x86_64 + '\n\n' + new_macos_arm64)

with open('build_libjpeg.sh', 'w') as f:
    f.write(text)

"""
print -n 'lipo: ios... '
xl $name '5_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libjpeg.a \
  -create -output $ROOT/lib/libjpeg-ios.a
print 'done.'

print -n 'lipo: sim... '
xl $name '5_sim_lipo' \
  xcrun lipo $ROOT/ios_arm64_sim/lib/libjpeg.a $ROOT/ios_x86_64_sim/lib/libjpeg.a \
  -create -output $ROOT/lib/libjpeg-sim.a
print 'done.'

print -n 'lipo: macos... '
xl $name '5_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libjpeg.a $ROOT/macos_arm64/lib/libjpeg.a \
  -create -output $ROOT/lib/libjpeg-macos.a
print 'done.'
"""

"""
print -n 'lipo: ios... '
xl $name '5_ios_lipo' \
  xcrun lipo $ROOT/ios_arm64/lib/libjpeg.a $ROOT/ios_x86_64/lib/libjpeg.a \
  -create -output $ROOT/lib/libjpeg.a
print 'done.'

print -n 'lipo: macos... '
xl $name '5_macos_lipo' \
  xcrun lipo $ROOT/macos_x86_64/lib/libjpeg.a \
  -create -output $ROOT/lib/libjpeg-macos.a
print 'done.'
"""