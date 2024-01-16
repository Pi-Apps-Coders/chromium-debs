#!/bin/bash

deb_list="chromium-browser-l10n
chromium-browser
chromium-codecs-ffmpeg
chromium-codecs-ffmpeg-extra
chromium-codecs-ffmpeg-dbgsym
chromium-codecs-ffmpeg-extra-dbgsym
chromium-browser-dbgsym
chromium-chromedriver
libwidevinecdm0"

rootpath="https://archive.raspberrypi.com/debian/"
Packages_arm64_url="${rootpath}dists/bookworm/main/binary-arm64/Packages"
Packages_armhf_url="${rootpath}dists/bookworm/main/binary-armhf/Packages"

Packages_arm64="$(wget -O- "$Packages_arm64_url")"
Packages_armhf="$(wget -O- "$Packages_armhf_url")"

mkdir -p debian
cd debian || exit 1
rm -rf ./*

IFS=$'\n'
for deb in $deb_list; do
    arm64_webVer="$(echo "$Packages_arm64" | awk "/Package: $deb\n/" RS= | grep "Version:" | awk '{print $2}' | sort -V | tail -n1)"
    echo "$arm64_webVer"
    armhf_webVer="$(echo "$Packages_armhf" | awk "/Package: $deb\n/" RS= | grep "Version:" | awk '{print $2}' | sort -V | tail -n1)"
    echo "$armhf_webVer"
    arm64_package_path="$(echo "$Packages_arm64" | awk "/Package: $deb\n/" RS= | sed -n -e "/Version: ${arm64_webVer}/,/Filename:/ p" | grep "Filename:" | awk '{print $2}')"
    armhf_package_path="$(echo "$Packages_armhf" | awk "/Package: $deb\n/" RS= | sed -n -e "/Version: ${armhf_webVer}/,/Filename:/ p" | grep "Filename:" | awk '{print $2}')"

    filename_arm64="$(basename "$arm64_package_path")"
    filename_armhf="$(basename "$armhf_package_path")"

    if [[ "$arm64_package_path" == "$armhf_package_path" ]]; then
        wget "$rootpath$arm64_package_path"
    else
        wget "$rootpath$arm64_package_path"
        wget "$rootpath$armhf_package_path"
    fi
done
