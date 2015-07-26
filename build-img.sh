#!/bin/bash
TOOLDIR="$(dirname $0)"
source "$TOOLDIR/utility-functions.inc"

# Build & hack a kickstart file and use it to make the final image
# To be executed under the Mer SDK



[ -z "$MERSDK" ] && ${TOOLDIR}/exec-mer.sh $0
[ -z "$MERSDK" ] && exit 0

source ~/.hadk.env
source ~/lavello/sfa-mer/proxy
cd $ANDROID_ROOT
set -x
#mkdir -p $ANDROID_ROOT/droid-local-repo/$DEVICE || die
createrepo $ANDROID_ROOT/droid-local-repo/$DEVICE || die
sb2 -t $VENDOR-$DEVICE-$ARCH -R -msdk-install zypper ref || die
sb2 -t $VENDOR-$DEVICE-$ARCH ssu lr || die

mchapter "8.2"
mkdir -p tmp
KSFL=$ANDROID_ROOT/tmp/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks

minfo "Adaptation"
HA_REPO="repo --name=adaptation0-$DEVICE-@RELEASE@"
if repo_is_set "$DHD_REPO"; then
   sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install cat /usr/share/kickstarts/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks > $KSFL || die
  minfo "dhd"
  HA_REPO1="repo --name=adaptation1-$DEVICE-@RELEASE@ --baseurl=${DHD_REPO}"
  sed -i -e "/^$HA_REPO.*$/a$HA_REPO1" $KSFL
  sed -i "/end 70_sdk-domain/a sed -i -e 's|^adaptation=.*$|adaptation=${DHD_REPO}|' /usr/share/ssu/repos.ini" $KSFL
else 
   sed -e "s|^$HA_REPO.*$|$HA_REPO --baseurl=file://$ANDROID_ROOT/droid-local-repo/$DEVICE|" \
    $ANDROID_ROOT/hybris/droid-configs/installroot/usr/share/kickstarts/$(basename $KSFL) > $KSFL
fi
if repo_is_set "$MW_REPO"; then
    minfo "add mw repo"
    HA_REPO2="repo --name=mw-$DEVICE-@RELEASE@ --baseurl=${MW_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO2" $KSFL
fi
if repo_is_set "$EXTRA_REPO"; then
    minfo "add mw repo"
    HA_REPO3="repo --name=extra-$DEVICE-@RELEASE@ --baseurl=${EXTRA_REPO}"
    sed -i -e "/^$HA_REPO.*$/a$HA_REPO3" $KSFL
    sed -i "/end 70_sdk-domain/a sed -i -e 's|^adaptation=.*$|adaptation=${EXTRA_REPO}|' /usr/share/ssu/repos.ini" $KSFL
fi

minfo "extra packages"
# Not sure about them, yet... maybe include an external per-device file
PACKAGES_TO_ADD="sailfish-office jolla-calculator jolla-email jolla-notes jolla-clock jolla-mediaplayer jolla-calendar strace"
PACKAGES_TO_ADD="$PACKAGES_TO_ADD jolla-settings-layout sailfish-weather "
PACKAGES_TO_ADD="$PACKAGES_TO_ADD gstreamer1.0-droid "
PACKAGES_TO_ADD="$PACKAGES_TO_ADD harbour-cameraplus apkenv"
#if repo_is_set "$EXTRA_REPO"; then
#   PACKAGES_TO_ADD="$PACKAGES_TO_ADD susepaste harbour-poor-maps less sailfish-utilities harbour-sailbusdublin  jolla-ambient-z1.5 ambient-icons-closed-z1.5"
#fi
#PACKAGES_TO_ADD="pulseaudio-modules-droid"
# jolla-fileman is no longer available starting update13. Download "File Manager" from store instead.
# Add it only to older versions (iirc it never worked anyway as per NEMO#796)
if [[ $(zypper vcmp $RELEASE 1.1.4.28) == *"is older"* ]]; then
  PACKAGES_TO_ADD=$PACKAGES_TO_ADD " jolla-fileman"
fi

#PACKAGES_TO_ADD="$PACKAGES_TO_ADD gstreamer0.10-droidcamsrc gstreamer0.10-colorconv gstreamer0.10-droideglsink libgstreamer0.10-nativebuffer libgstreamer0.10-gralloc gstreamer0.10-omx"

for pack in $PACKAGES_TO_ADD; do 
  sed -i "/@Jolla\ Configuration\ $DEVICE/a $pack" $KSFL
done

#PACKAGES_TO_REMOVE="ofono-configs-mer ssu-vendor-data-example qtscenegraph-adaptation "
PACKAGES_TO_REMOVE="jolla-camera jolla-camera-settings"
for pack in $PACKAGES_TO_REMOVE; do
  sed -i "/@Jolla\ Configuration\ $DEVICE/a -$pack" $KSFL
done
#sed -i "s;@Jolla\ Configuration\ $DEVICE;@jolla-configuration-hammerhead;g" $KSFL
mchapter "Add adaptation and extra repos in image"

sed -i '/%post --nochroot/a cp $INSTALL_ROOT'//etc//sailfish-release' $IMG_OUT_DIR' $KSFL
sed -i 's|/etc/sailfish-release||' $KSFL

if repo_is_set "$MW_REPO"; then
  sed -i "/begin 60_ssu/a ssu ar mw $MW_REPO" $KSFL
fi
if repo_is_set "$DHD_REPO"; then
  sed -i "/begin 60_ssu/a ssu ar dhd $DHD_REPO" $KSFL
fi
if repo_is_set "$EXTRA_REPO"; then
  sed -i "/begin 60_ssu/a ssu ar extra $EXTRA_REPO" $KSFL
fi
sed -i "/begin 60_ssu/a zypper rm jolla-camera jolla-camera-settings" $KSFL
sed -i "/begin 60_ssu/a ssu dr adaptation0" $KSFL

#debug merdre
#sed -i "s/@Jolla Configuration $DEVICE/@jolla-hw-adaptation-$DEVICE/g" $KSFL
#sed -i "s/@Jolla Configuration $DEVICE/droid-config-hammerhead-policy-settings/g" $KSFL
mchapter "8.3"
minfo "Info: create patterns"
[ -d hybris ] || mkdir -p hybris
 ./hybris/droid-configs/droid-configs-device/helpers/process_patterns.sh || die
cat $KSFL > ~/a.ks
mchapter "8.4"
minfo "create mic"
# always aim for the latest:
RELEASE=1.1.7.24
#RELEASE=latest
# WARNING: EXTRA_NAME currently does not support '.' dots in it!
EXTRA_NAME=-${EXTRA_STRING}-$(date +%Y%m%d%H%M)
sudo mic create fs --arch $ARCH \
  --tokenmap=ARCH:$ARCH,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME \
  --record-pkgs=name,url \
  --outdir=sfa-$DEVICE-$RELEASE$EXTRA_NAME \
  --pack-to=sfa-$DEVICE-$RELEASE$EXTRA_NAME.tar.bz2 \
  $KSFL 2>&1 | tee mic.log  || die
minfo "Info: copy image"
mkdir -p "$IMGDEST" || die
cp -av sfa-${DEVICE}-${RELEASE}${EXTRA_NAME}/sailfishos-${DEVICE}-release-${RELEASE}${EXTRA_NAME}.zip "$IMGDEST"/ || die

#clean repos in target
minfo "Info: clean repos in target"

if repo_is_set "$MW_REPO"; then
  sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu rr mw-$DEVICE-hal
fi
if repo_is_set "$EXTRA_REPO"; then
  sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu rr extra-$DEVICE
fi
if repo_is_set "$DHD_REPO"; then
  sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu rr dhd-$DEVICE-hal
fi
sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu rr local-$DEVICE-hal
sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install zypper ref -f
sb2 -t $VENDOR-$DEVICE-$ARCH -R -m sdk-install ssu lr

 
