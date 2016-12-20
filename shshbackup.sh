#!/bin/bash

# Usage
#
#	./shshbackup.sh 
#		Will prompt for information, saves to zip folder
#
#	./shshbackup.sh [Device] [ECID] [String]
#		Does not prompt. Downloads shsh2 for device and saves to 
#		a named zip file.
#
#	
#

function main () {
	
	# check we have a sudo cache
	printf -- "--> shshsave.sh needs your root password to continue.\n--> You can also exit the program, run sudo printf, and restart.\n-->\n"
	while [ "x$(sudo --prompt='--> Enter password for %u: ' whoami)" != "xroot" ]; do
		true
	done
	clear

	# check if we are root
	if [ "x$(whoami)" == "xroot" ]; then
		clear
		printf -- "--> shshsave.sh cannot be run as root!\n"
		printf -- "-->   shshsave needs to access your home directory, and it can't\n"
		printf -- "-->   find your username when run as root. Rerun without sudo, \n"
		printf -- "-->   and shshsave.sh will prompt for a root password\n-->\n"
		printf -- "--> Press any key to exit\n"
		read -n 1
		exit
	fi

	# make it pretty


	printf -- '-->######################################<--\n'
	printf -- '-->#      _____ __  _______ __  __      #<--\n'
	printf -- '-->#     / ___// / / / ___// / / /      #<--\n'
	printf -- '-->#     \__ \/ /_/ /\__ \/ /_/ /       #<--\n'
	printf -- '-->#    ___/ / __  /___/ / __  /        #<--\n'
	printf -- '-->#   /_______ /_//____/_/ /_/         #<--\n'
	printf -- '-->#     / ___/____ __   _____  _____   #<--\n'
	printf -- '-->#     \__ \/ __ `/ | / / _ \/ ___/   #<--\n'
	printf -- '-->#    ___/ / /_/ /| |/ /  __/ /       #<--\n'
	printf -- '-->#   /____/\__,_/ |___/\___/_/        #<--\n'
	printf -- '-->#                                    #<--\n'
	printf -- '-->######################################<--\n'

		           #now with 100% more ascii art

	# set some vars
	SHOULDSHOWPROMPTS=
	VERBOSE=0

	# check vars
	case "$#" in
		"0")
			SHOULDSHOWPROMPTS=1
			printf -- -- "--> No args specifed, will prompt for device/ecid\n"
			download
			resp=n
			while [ "x$resp" != "xy" ]
			do 
				printf -- "-->\n--> Enter your Model ID (Eg. \"iPhone8,1\"): "
				read MODELID

				# check it
				printf -- "--> Is \"$MODELID\" correct? (y/n)"
				read -n 1 resp
				printf "\n"
			done
			resp=n
			while [ "x$resp" != "xy" ]
			do 
				printf -- "-->\n--> Enter your ECID (Eg. \"12346AB6CD\"): "
				read ECID
				printf -- "--> Is \"$ECID\" correct? (y/n)"
				read -n 1 resp
				printf "\n"
			done
			DIRECTORY=$(printf "%s-%s-%s" "$(echo $MODELID | tr ',' '_')" "$ECID" "none" )
			mkdir $DIRECTORY
			cd $DIRECTORY
			getshsh $MODELID $ECID
			cleanup $DIRECTORY
		;;
		"3")
			printf -- "--> Automatic mode!\n"
			DIRECTORY=$(printf "%s-%s-%s" "$(echo $1 | tr ',' '_')" "$2" "$3" )
			printf -- "-->\n-->\tDevice:\t$1\n-->\tECID:\t$2\n-->\tName:\t$3\n-->\n"
			printf -- "--> Creating folder: ./%s/\n" "$DIRECTORY"
			mkdir $DIRECTORY
			cd $DIRECTORY
			download
			getshsh $1 $2 $3
			cleanup $DIRECTORY
		;;
		*)
			printf -- "--> Unknown command!"
			exit
		;;
	esac

	printf "\n\n\nSomthing unexpected happened! Report this please!\n"
	sleep 10
	exit




	

	





}

function getshsh () { #modelid #ecid

	# we start in the iPhone0,0-12345-test

	# print it
	printf -- "--> Getting shsh...\n"

	MODELID="-d $1"
	ECID="-e $2"

	# uncomment if needed
	#local DEBUG="YES PLZ"

	# save nonce'd versions
	nonces[0]=""
	nonces[1]="--apnonce 352dfad1713834f4f94c5ff3c3e5e99477347b95"
	nonces[2]="--apnonce 603be133ff0bdfa0f83f21e74191cf6770ea43bb"
	nonces[3]="--apnonce 42c88f5a7b75bc944c288a7215391dc9c73b6e9f"
	nonces[4]="--apnonce 0dc448240696866b0cc1b2ac3eca4ce22af11cb3"
	nonces[5]="--apnonce 9804d99e85bbafd4bb1135a1044773b4df9f1ba3"
	versions[0]="-i 10.2 -s"
	versions[1]="-i 10.1.1 --buildid 14B150"
	versions[2]="-i 10.1.1 --buildid 14B100"
	versions[3]="-i 10.1"

	#just in case
	chmod +wr .

	for nonce in "${nonces[@]}"
	do
		if [[ -z  "$nonce"  ]]; then
			printf -- "--> Getting rand "
			mkdir rand-nonce
			cd rand-nonce
		else
			MYVAR=$(printf "%s" "$nonce" | grep -o '...$')
			printf -- "--> Getting x$MYVAR "
			mkdir $MYVAR
			cd $MYVAR
		fi
		touch log_shsh.txt
		for version in "${versions[@]}"
		do	
			[[ ! -z  "$DEBUG"  ]] && printf -- "--> DEBUG: %s,%s,%s,%s\n" "$MODELID" "$ECID" "$version" "$nonce"
			../../tsschecker $MODELID $ECID $version $nonce >> log_shsh.txt
			rc=$?; if [[ $rc != 0 ]]; then
			printf -- "-->\tSHSH Download FAILED!\n-->\n-->\tdir:%s\n-->\tnonce: %s\n-->\tfailed on version: %s\n-->\n--> Ensure the values above are correct, and check that you're connected\n--> to the internet. You may need the IPSWs for the above firmware.\n-->" "$(pwd)" "$nonce" "$version"

			exit $rc # pass on original error code from tsschecker
			fi
			printf "... "
		done
		printf " done\n"
		cd ..

	done
}


function download () {

	local TSSCHECKERVER="1.0.5"
	local TSSCHECKERURL="https://github.com/tihmstar/tsschecker/releases/download/v1.0.5/tsschecker_1.0.5_osx.zip"
	local TSSCHECKERSHA="df935862b6c32f59a6bc892918e07d69ddc0d0b1"


	# check if we have a valid, executable version
	if [ -x tsschecker ]; then
		openssl sha1 tsschecker | grep "0123456789qwertyuiopasdfghjklzxcvbnm1234" >> /dev/null && echo "--> TSSChecker 0.0.0 found... skipping..." && return || true
		openssl sha1 tsschecker | grep "df935862b6c32f59a6bc892918e07d69ddc0d0b1" >> /dev/null && echo "--> TSSChecker 1.0.5 found... skipping..." && return || true

		# if we have an unidentified version of tsschecker, delete and redownload
		rm tsschecker
	fi

	# if it exists but isn't executable
	if [ -f tsschecker ]; then 
		chmod +x tsschecker
	fi

	printf -- "--> TSSChecker not found\n"
	printf -- "--> Downloading tsschecker $TSSCHECKERVER\n"

	# curl it
	curl -Ls $TSSCHECKERURL -o tsschecker.zip >> log.txt && printf -- "-->\tDownload OK...\n" || $(printf "Download FAILED, See log.txt. Exiting" && exit)

	# unzip it
	unzip tsschecker.zip >> log.txt && printf -- "-->\tUnzip OK...\n" || $(echo "--> Unzip FAILED. See log.txt. Exiting" && exit)

	# break it
	chmod -x tsschecker

	# check it 
	openssl sha1 tsschecker | grep "$TSSCHECKERSHA" >> log.txt && printf -- "-->\tSHA1 OK...\n" || $(echo "--> SHA1 FAILED. See log.txt. Exiting!" && exit)

	# fix it
	chmod +xrw tsschecker && printf -- "-->\tPermissions OK...\n" || $(echo "--> CHMOD ADD EXEC FAILED. See log.txt. Exiting!" && exit)

	printf -- "--> TSSChecker $TSSCHECKERVER downloaded.\n"

}

function cleanup () {
	cd ..
	zip -r $1 $1 >> ./$1/ziplog.txt && rm -r $1 || printf -- "--> ZIP FAIL! \n"
	printf -- "--> Finished! Saved to $DIRECTORY.zip\n-->\n-->exiting\n"

	# uncomment to open at end
	open .

	exit
}

function getblobs () { #model, ecid, name
	true
}


main $1 $2 $3 $4 $5 $6
exit


