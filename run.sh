#!/usr/bin/env bash

FABRIC_MANAGER_VERSION=""
FABRIC_MANAGER_URL=""
IS_XZ=0

check_url() {
	url=$1
	if [[ $url == "" ]];then
		return 1
	fi
	url=$(echo $url |sed -e 's@//@/@g'| sed -e 's@:/@://@g')
	for i in $(seq 1 10);do
		code=$(curl -k -I --max-time 10 $url 2>&1 | awk '/HTTP\// {print $2}')
		if [[ $code =~ 20.* ]];then
			echo "url $url is available"
			return 0
		fi
		sleep 1
	done
	echo "$url is not available"
	return 1
}

download_and_fabric_manager() {
    baseurl="https://developer.download.nvidia.cn/compute/cuda/redist/fabricmanager/linux-x86_64/"
    if check_url "$baseurl/fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION.tar.gz"; then
        export FABRIC_MANAGER_URL="$baseurl/fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION.tar.gz"
    elif check_url "$baseurl/fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION-archive.tar.xz"; then
        export FABRIC_MANAGER_URL="$baseurl/fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION-archive.tar.xz"
        export IS_XZ=1
    else
        echo "The fabricmanager version you support is invalid."
        return 1
    fi
    wget $FABRIC_MANAGER_URL -P /
    return 0
}

build_rpm() {
    if [[ "1" == "$IS_XZ" ]]; then
        decompress_and_recompress_xz
    fi
    mv /fabricmanager*.tar.gz /work/SOURCES/
    cd /work
    rpmbuild \
    --define "%_topdir /data" \
    --define "%version $FABRIC_MANAGER_VERSION" \
    --define "%_arch x86_64" \
    --define "%_build_arch x86_64" \
    --target=x86_64 \
    -v -ba SPECS/*.spec
}

decompress_and_recompress_xz() {
    tar -xvf /fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION-archive.tar.xz -C /
    dir=/fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION-archive
    mv $dir/bin/* $dir && rm -rf $dir/bin
    mv $dir/etc/* $dir && rm -rf $dir/etc
    mv $dir/include/* $dir && rm -rf $dir/include
    mv $dir/lib/* $dir && rm -rf $dir/lib
    mv $dir/sbin/* $dir && rm -rf $dir/sbin
    mv $dir/share/nvidia/nvswitch/* $dir && rm -rf $dir/share
    mv $dir/systemd/* $dir && rm -rf $dir/systemd
    mv /fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION-archive /fabricmanager
    tar -czvf fabricmanager-linux-x86_64-$FABRIC_MANAGER_VERSION.tar.gz /fabricmanager
}

main() {
    if [[ "" == "$1" ]]; then
        echo ""
        return
    fi

    export FABRIC_MANAGER_VERSION="$1"
    if download_fabric_manager; then 
        build_rpm
        echo "Build done."
    else
        return
    fi
}

main "$@"
