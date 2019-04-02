#! /bin/bash

## Multi-container extension paths
BASEPATH=~/.mozilla/firefox
#BASEPATH=/tmp/profile0/
CONTAINERS_FILE="containers.json"
PREFS_FILE="prefs.js"
CONTAINERS_PREFS_IDENTIFIER='\\"@testpilot-containers\\":\\"'

USAGE="Usage:
---- Using files
Export to zip               \t\t./ffcontainers.sh export
Import from zip             \t\t./ffcontainers.sh import [nameOfTheZip]
---- Using Firefox Send
Export to Firefox Send URI  \t\t./ffcontainers.sh fsexport
Import from Firefox Send URI\t\t./ffcontainers.sh fsimport [firefoxSendURI]"

FIREFOX_PROFILES=$(ls $BASEPATH/*.default*/$CONTAINERS_FILE)
NUMBER_FIREFOX_PROFILES=$(wc -w <<< $FIREFOX_PROFILES)
if [[ -z $NUMBER_FIREFOX_PROFILES ]]; then
	echo "ERROR: no Firefox installation detected on this system"
	exit 1
fi


## Functions
export_containers(){
	USE_FFSEND=$1

	DATE=$(date +%Y%m%d)
	if [[ $NUMBER_FIREFOX_PROFILES -gt 1 ]]; then
		## Multi-profile Firefox
		echo "Multiple Firefox profiles with containers detected"
		echo "Select the number of profile to export containers from"

		let i=1
		echo -e "NUMBER\t\tCONTAINERS"
		for PROFILE in $FIREFOX_PROFILES
		do
			echo -e "\033[1m $i \033[0m \t" $(jq '.identities[]["name"]' "$PROFILE" | grep -v userContextIdInternal | tr -s $'\n' ',')
			let i=i+1
		done
		read i
		PROFILE=$(cut -d ' ' -f $i <<< $FIREFOX_PROFILES | rev | cut -d '/' -f 2 | rev)
	else
		## Mono-profile Firefox
		PROFILE=$(rev <<< $FIREFOX_PROFILES | cut -d '/' -f 2 | rev)
	fi

	ADDON_ID=$(grep $CONTAINERS_PREFS_IDENTIFIER $BASEPATH/$PROFILE/$PREFS_FILE | sed "s/.*$CONTAINERS_PREFS_IDENTIFIER//g" | cut -d '\' -f1)
	STORAGE_PATH_PREFIX="storage/default/moz-extension+++$ADDON_ID"

	OUTPUT_FILE="ffcontainers-$PROFILE-$DATE.zip"
	zip -q -j $OUTPUT_FILE "$BASEPATH/$PROFILE/$CONTAINERS_FILE" $BASEPATH/$PROFILE/$STORAGE_PATH_PREFIX*/idb/*sqlite

	echo -n "Containers successfully exported in: "
	if [[ $USE_FFSEND -eq 0 ]]; then
		URI='https:'$(ffsend --no-interact upload $OUTPUT_FILE 2>&1 | cut -d ':' -f3)
		OUTPUT_FILE=$URI
	fi
	echo -e "\033[1m$OUTPUT_FILE\033[0m"
}

import_containers(){
	USE_FFSEND=$1
	INPUT_FILE=$2
	TMP_DIR=".tmpdir"
	mkdir -p $TMP_DIR

	if [[ $USE_FFSEND -eq 0 ]]; then
		pushd $TMP_DIR > /dev/null
		ffsend --no-interact download $INPUT_FILE
		INPUT_FILE=$PWD/$(ls)
		popd > /dev/null
	fi

	if [[ $NUMBER_FIREFOX_PROFILES -gt 1 ]]; then
		## Multi-profile Firefox
		echo "Multiple Firefox profiles with containers detected"
		echo "Select the number of profile to import containers to"
		
		let i=1
		for PROFILE in $FIREFOX_PROFILES
		do
			echo $i $( cut -d ' ' -f $i <<< $FIREFOX_PROFILES | cut -d '/' -f 6)
			let i=i+1
		done
		read i
		PROFILE=$(cut -d ' ' -f $i <<< $FIREFOX_PROFILES | rev | cut -d '/' -f 2 | rev)
	else
		## Mono-profile Firefox
		PROFILE=$(rev <<< $FIREFOX_PROFILES | cut -d '/' -f 2 | rev)
	fi

	ADDON_ID=$(grep $CONTAINERS_PREFS_IDENTIFIER $BASEPATH/$PROFILE/$PREFS_FILE | sed "s/.*$CONTAINERS_PREFS_IDENTIFIER//g" | cut -d '\' -f1)
	STORAGE_PATH_PREFIX="storage/default/moz-extension+++$ADDON_ID"

	unzip -q $INPUT_FILE -d $TMP_DIR
	mv "$TMP_DIR/$CONTAINERS_FILE" "$BASEPATH/$PROFILE/$CONTAINERS_FILE"
	mv $TMP_DIR/*sqlite $BASEPATH/$PROFILE/$STORAGE_PATH_PREFIX*/idb/*sqlite
	rm -r $TMP_DIR
	
	echo -e "Containers successfully imported in profile $PROFILE"
}

if [[ "$1" == *"export" ]]; then
	test $1 == "fsexport"
	USE_FFSEND=$?
	export_containers $USE_FFSEND
elif [[ "$1" == *"import" && -n $2 ]]; then
	test $1 == "fsimport"
	USE_FFSEND=$?
	import_containers $USE_FFSEND $2
else
	echo -e "$USAGE"
fi

