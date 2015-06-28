#!/bin/bash

# Build droid-hal and other middleware
# To be executed under the Mer SDK


[ -z "$MERSDK" ] && $(dirname $0)/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env

cd $ANDROID_ROOT
# THE COMMAND BELOW WILL FAIL. It's normal, carry on with the next one.
# Explanation: force installing of build-requirements by specifying the
# .inc file directly, but build-dependencies will be pulled in via
# zypper, so that the next step has all macro definitions loaded



  #sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
  #sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper in "pkgconfig(gstreamer-1.0)" "pkgconfig(gstreamer-base-1.0)" "pkgconfig(gstreamer-video-1.0)" "pkgconfig(gstreamer-plugins-bad-1.0)" "pkgconfig(gstreamer-tag-1.0)" nemo-gstreamer1.0-interfaces-devel "pkgconfig(libexif)"
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install ssu ar gst http://repo.merproject.org/obs/nemo:/devel:/hw:/common/sailfish_latest_armv7hl/ 
  sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
    PKG=gst-droid
    echo -e "\e[01;32m Info: build $PKG\e[00m"
    SPEC=$PKG
    mkdir -p $MER_ROOT/devel/mer-hybris
    
    cd $MER_ROOT/devel/mer-hybris
    if [ -d $PKG ] ; then
      echo -e "\e[01;32m Info: update the git $PKG\e[00m"
      cd $PKG
      git pull
    else
      echo -e "\e[01;32m Info: clone the git $PKG\e[00m"
      git clone https://github.com/foolab/$PKG.git 
      #git clone https://github.com/foolab/$PKG.git -b droidmedia
      #git clone https://github.com/foolab/$PKG.git -b caps
      cd $PKG
    fi

    echo -e "\e[01;32m Info: mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $PKG.log \e[00m"
    mb2 -s rpm/$PKG.spec -t $VENDOR-$DEVICE-armv7hl build &> $ANDROID_ROOT/$PKG.log 
    tail -n 5 $ANDROID_ROOT/$PKG.log
    mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/
    rm -f $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG/*.rpm
    mv RPMS/*.rpm $ANDROID_ROOT/droid-local-repo/$DEVICE/$PKG
    createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE
    sb2 -t $VENDOR-$DEVICE-armv7hl -R -msdk-install zypper ref
