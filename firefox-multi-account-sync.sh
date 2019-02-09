#! /bin/bash


## Multi-container extension paths
BASEPATH=~/.mozilla/firefox
CONTAINERS="containers.json"
STORAGE="browser-extension-data/@testpilot-containers/storage.js"

USAGE="Usage:
Export to zip  \t\tfirefox-multi-account-sync export
Import from zip\t\tfirefox-multi-account-sync import [nameofthezip]"

FIREFOX_PROFILES=$(ls $BASEPATH/*.default/$CONTAINERS)

if [[ "$1" == "export" ]]; then
	DATE=$(date +%Y%m%d)

	if [[ $(wc -w <<< $FIREFOX_PROFILES) -gt 1 ]]; then
		## Multi-profile Firefox
		echo "Multiple Firefox profiles with containers detected"
		echo "Select the number of profile to export"

		let i=1
		echo -e "NUMBER\t\tCONTAINERS"
		for PROFILE in $FIREFOX_PROFILES
		do
			echo -e "\033[1m $i \033[0m \t" $(jq '.identities[]["name"]' "$PROFILE" | grep -v userContextIdInternal | tr -s $'\n' ',')
			let i=i+1
		done
		read i
		PROFILE=$( cut -d ' ' -f $i <<< $FIREFOX_PROFILES | cut -d '/' -f 6)
	else
		## Mono-profile Firefox
		PROFILE=$(cut -d '/' -f 6 <<< $FIREFOX_PROFILES)
	fi

	OUTPUTFILE="multicontainer-$PROFILE-$DATE.zip"
	zip $OUTPUT_FILE "$BASEPATH/$PROFILE/$CONTAINERS" "$BASEPATH/$PROFILE/$STORAGE"
	echo -e "Containers successfully exported in:\t \033[1m$OUTPUTFILE\033[0m"
elif [[ "$1" == "import" ]]; then
	echo "Importing..."
	## TODO check version
else
	echo -e "$USAGE"
fi

