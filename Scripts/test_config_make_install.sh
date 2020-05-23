#! /bin/zsh

# Tried doing it the right way, `shellcheck source=build.sh`, but still got error
# shellcheck disable=SC1091
# Include unittest positional arg so build.sh doesn't try to build anything
source build.sh unittest

_assertContains() {
  if echo $1 |grep -F -- $2 >/dev/null; then
    return 0
  else
    return 1
  fi
}

_assertNotContains() {
  if echo $1 |grep -F -- $2 >/dev/null; then
    return 1
  else
    return 0
  fi
}

testVarsDoNotAccumulateTargetValues() {
  # A bug in libtiff.sh caused the CXXFLAGS_ARR var to accumulate conflicting
  # values as the build script looped over the targets, creating errors like:
  #
  #   Logs/tiff-4.1.0/5_ios_x86_64_install.err:6:/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator13.4.sdk/usr/include/sys/cdefs.h:807:2: error: Unsupported architecture
  #   Logs/tiff-4.1.0/5_ios_x86_64_install.err:7:#error Unsupported architecture
  #
  # which is a head-scratcher because iPhoneSimulator *is* the platform architecture for ios_x86_64.  The error
  # eventually revealed that iPhoneSimulator conflicted with iPhoneOS, which was found first when CXXFLAGS was parsed:
  # 
  #   CXXFLAGS=\
  #     -arch=arm64 ...iPhoneOS.platform/**/iPhoneOS13.4.sdk ... \
  #     -arch=x86_64 ...iPhoneSimulator.platform/**/iPhoneSimulator13.4.sdk ...
  #
  # There was a very simple and concrete error message stating that both -miphoneos-version-min=11.0 and 
  # -mios-simulator-version-min=11.0 were set and were in conflict, but I cannot seem to generate/find that error now.
  #
  # The solutiong was chaninging CXXFLAGS_ARR=(CXXFLAGS_ARR CFLAGS) to CXXFLAGS_ARR=(CXXFLAGS CFLAGS).

  ALL_ERR_MSGS=()
  for target in libjpeg libpng libtiff
  do
    source configs/${target}.sh

    ERR_MSG=()

    # Set iOS envvars
    ios_arm64

    assertNotNull "$CXXFLAGS"
    if ! _assertContains "$CXXFLAGS" '-miphoneos-version-min=11.0' ; then
      ERR_MSG=($ERR_MSG '\nios_arm64:\tfor iPhone-only platform,\t\trequired iPhoneOS not found')
    fi

    if ! _assertNotContains "$CXXFLAGS" '-mios-simulator-version-min=11.0' ; then
      ERR_MSG=($ERR_MSG '\nios_arm64:\tfor iPhone-only platform,\t\tconflicting iPhoneSimulator found')
    fi

    if ! _assertNotContains "$CXXFLAGS" '-mmacosx-version-min=10.13' ; then
      ERR_MSG=($ERR_MSG '\nios_arm64:\tfor iPhone-only platform,\t\tconflicting macOS found')
    fi

  # Set simulator envvars
    ios_x86_64

    assertNotNull "$CXXFLAGS"
    if ! _assertContains "$CXXFLAGS" '-mios-simulator-version-min=11.0' ; then
      ERR_MSG=($ERR_MSG '\nios_x86_64:\tfor iPhoneSimulator-only platform\trequired iPhoneSimulator not found')
    fi

    if ! _assertNotContains "$CXXFLAGS" '-miphoneos-version-min=11.0' ; then
      ERR_MSG=($ERR_MSG '\nios_x86_64:\tfor iPhoneSimulator-only platform\tconflicting iPhoneOS found')
    fi

    if ! _assertNotContains "$CXXFLAGS" '-mmacosx-version-min=10.13' ; then
      ERR_MSG=($ERR_MSG '\nios_x86_64:\tfor iPhoneSimulator-only platform\tconflicting macOS found')
    fi

    # Set macOS envvars
    macos_x86_64

    assertNotNull "$CXXFLAGS"
    if ! _assertContains "$CXXFLAGS" '-mmacosx-version-min=10.13' ; then
      ERR_MSG=($ERR_MSG '\nmacos_x86_64:\tfor macOS-only platform\t\t\trequired macOS not found')
    fi

    if ! _assertNotContains "$CXXFLAGS" '-miphoneos-version-min=11.0' ; then
      ERR_MSG=($ERR_MSG '\nmacos_x86_64:\tfor macOS-only platform\t\t\tconflicting iPhoneOS found')
    fi

    if ! _assertNotContains "$CXXFLAGS" '-mios-simulator-version-min=11.0' ; then
      ERR_MSG=($ERR_MSG '\nmacos_x86_64:\tfor macOS-only platform\t\t\tconflicting iPhoneSimulator found')
    fi

    if [ -n "$ERR_MSG" ]; then
      ERR_MSG=("\n\n$target" $ERR_MSG)
      ALL_ERR_MSGS=($ALL_ERR_MSGS $ERR_MSG)
    fi
  done

  if [ -n "$ALL_ERR_MSGS" ]; then

    fail "$ALL_ERR_MSGS\n"
  fi
}

setopt shwordsplit
export SHUNIT_PARENT=$0

# shellcheck disable=SC1091
source shunit2/shunit2
