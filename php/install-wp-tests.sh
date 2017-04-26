#!/usr/bin/env bash

WP_VERSION=${1}

WP_TESTS_DIR=/tmp/wordpress-tests-lib-${WP_VERSION}/
WP_CORE_DIR=/tmp/wordpress-${WP_VERSION}/

download() {
    if [ `which curl` ]; then
        curl -s "$1" > "$2";
    elif [ `which wget` ]; then
        wget -nv -O "$2" "$1"
    fi
}

if [[ $WP_VERSION =~ [0-9]+\.[0-9]+(\.[0-9]+)? ]]; then
	WP_TESTS_TAG="tags/$WP_VERSION"
elif [[ $WP_VERSION == 'nightly' || $WP_VERSION == 'trunk' ]]; then
	WP_TESTS_TAG="trunk"
else
	# http serves a single offer, whereas https serves multiple. we only want one
	download http://api.wordpress.org/core/version-check/1.7/ /tmp/wp-latest.json
	grep '[0-9]+\.[0-9]+(\.[0-9]+)?' /tmp/wp-latest.json
	LATEST_VERSION=$(grep -o '"version":"[^"]*' /tmp/wp-latest.json | sed 's/"version":"//')
	if [[ -z "$LATEST_VERSION" ]]; then
		echo "Latest WordPress version could not be found"
		exit 1
	fi
	WP_TESTS_TAG="tags/$LATEST_VERSION"
fi

install_wp() {

    mkdir -p $WP_CORE_DIR

    if [[ $WP_VERSION == 'nightly' || $WP_VERSION == 'trunk' ]]; then
	mkdir -p /tmp/wordpress-nightly
	download https://wordpress.org/nightly-builds/wordpress-latest.zip  /tmp/wordpress-nightly/wordpress-nightly.zip
	unzip -q /tmp/wordpress-nightly/wordpress-nightly.zip -d /tmp/wordpress-nightly/
	mv /tmp/wordpress-nightly/wordpress/* $WP_CORE_DIR
    else
	if [ $WP_VERSION == 'latest' ]; then
	    local ARCHIVE_NAME='latest'
	else
	    local ARCHIVE_NAME="wordpress-$WP_VERSION"
	fi
	download https://wordpress.org/${ARCHIVE_NAME}.tar.gz  /tmp/wordpress.tar.gz
	tar --strip-components=1 -zxmf /tmp/wordpress.tar.gz -C $WP_CORE_DIR
    fi

}

install_test_suite() {
    local ioption='-i'

    # set up testing suite if it doesn't yet exist
    if [ ! -d $WP_TESTS_DIR ]; then
	# set up testing suite
	mkdir -p $WP_TESTS_DIR
	svn co --quiet https://develop.svn.wordpress.org/${WP_TESTS_TAG}/tests/phpunit/includes/ $WP_TESTS_DIR/includes
    fi
}

install_wp
install_test_suite
