#!/bin/bash


# To resolve certificate errors,  /u/smurf3310 has suggested downloading the certificates from https://curl.haxx.se/ca/cacert.pem
# If you want to do this, uncomment the next line to enable this. 
# curl -Ls https://curl.haxx.se/ca/cacert.pem -o curl-ca-cert.crt && open curl-ca-cert.crt


printf ">> SHSH Saver!\n>\n"
clear
if [ "x$(whoami)" == "xroot" ]; then
	clear
	printf "> shshsave.sh cannot be run as root!\n"
	printf ">   shshsave needs to access your home directory, and it can't\n"
	printf ">   find your username when run as root. Rerun without sudo, \n"
	printf ">   and shshsave.sh will prompt for a root password\n>\n"
	printf "> Press any key to exit\n"
	read -n 1
	exit
fi
printf "> shshsave.sh needs your root password to continue.\n> You can also exit the program, run sudo printf, and restart.\n>\n"
echo -n "> Enter root password:"
while [ "x$(sudo whoami)" != "xroot" ];do #get user input
	true
done
clear 
printf "\n\n>> SHSH Saver!\n"
printf ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
printf "> Press ctrl+c to exit at any time.\n"
printf "> Root access OK...\n"
if test -d ~/shshbackup
then
	printf "> ~/shshbackup folder exists. Exiting\n>\n"
	printf "> Remove or rename this folder to continue. This check\n"
	printf "> is used to prevent accidental overwriting of shsh blobs.\n>\n> Exiting\n>\n"
 	exit && exit
 	sleep 1
fi

# make it
mkdir ~/shshbackup

# change it
chmod +rw ~/shshbackup	

# switch it
cd ~/shshbackup

# trash it
rm -f tsschecker.zip
rm -f tsschecker
rm -f log.txt

# touch it
touch log.txt


# curl it
curl -Ls https://github.com/tihmstar/tsschecker/releases/download/v1.0.5/tsschecker_1.0.5_osx.zip -o tsschecker.zip >> log.txt && printf "> Download OK...\n" || $(printf "Download FAILED, See log.txt. Exiting" && exit)

# unzip it
unzip tsschecker.zip >> log.txt && echo "> Unzip OK..." || $(echo "> Unzip FAILED. See log.txt. Exiting" && exit)

# break it
chmod -x tsschecker

# check it 
openssl sha1 tsschecker | grep "df935862b6c32f59a6bc892918e07d69ddc0d0b1" >> log.txt && echo "> SHA1 OK..." || $(echo "> SHA1 FAILED. See log.txt. Exiting!" && exit)

# fix it
chmod +x tsschecker

# touch it 
# bring it
# babe

# watch it
# turn it
# leave it

# technologic

resp=n
while [ "x$resp" != "xy" ]
do 
	printf ">\n> Enter your Model ID (Eg. \"iPhone8,1\"): "
	read MODELID

	# check it
	printf "> Is \"$MODELID\" correct? (y/n)"
	read -n 1 resp
	printf "\n"
done
resp=n
while [ "x$resp" != "xy" ]
do 
	printf ">\n> Enter your ECID (Eg. \"12346AB6CD\"): "
	read ECID
	printf "> Is \"$ECID\" correct? (y/n)"
	read -n 1 resp
	printf "\n"
done

# print it
printf "> Getting shsh. This may take a long time if you don't have the IPSW...\n"

# save nonceless versions
./tsschecker -d $MODELID -e $ECID -i 10.2 -s >> log_10_2.txt\
	&& printf ">    10.2 SHSH OK...\n" || printf ">    10.2 FAILED. See log.txt!\n"
./tsschecker -d $MODELID -e $ECID -i 10.1.1 --buildid 14B150 -s >> log_10_1_1_150.txt\
	&& printf ">    10.1.1b150 SHSH OK...\n" || printf ">    10.1.1 FAILED. See log.txt!\n"
./tsschecker -d $MODELID -e $ECID -i 10.1.1 --buildid 14B100 -s >> log_10_1_1_100.txt\
	&& printf ">    10.1.1b100 SHSH OK...\n" || printf ">    10.2 FAILED. See log.txt!\n"
./tsschecker -d $MODELID -e $ECID -i 10.1 -s >> log_10_1.txt\
	&& printf ">    10.1 SHSH OK...\n" || printf ">    10.2 FAILED. See log.txt!\n"

# save nonce'd versions
nonces=( 352dfad1713834f4f94c5ff3c3e5e99477347b95 603be133ff0bdfa0f83f21e74191cf6770ea43bb 42c88f5a7b75bc944c288a7215391dc9c73b6e9f 0dc448240696866b0cc1b2ac3eca4ce22af11cb3 9804d99e85bbafd4bb1135a1044773b4df9f1ba3 )
for nonce in "${nonces[@]}"
do
	printf "> Getting shsh with nonce %.4s...\n" "$nonce"
	mkdir $nonce && cd $nonce;
	../tsschecker -d $MODELID -e $ECID -i 10.2 -s --apnonce $nonce >> log_10_2.txt\
	&& printf ">    10.2 SHSH OK...\n" || printf ">    10.2 FAILED. See log.txt!\n"
	../tsschecker -d $MODELID -e $ECID -i 10.1.1 --buildid 14B150 -s --apnonce $nonce >> log_10_1_1_150.txt\
	&& printf ">    10.1.1b150 SHSH OK...\n" || printf ">    10.1.1 FAILED. See log.txt!\n"
	../tsschecker -d $MODELID -e $ECID -i 10.1.1 --buildid 14B100 -s --apnonce $nonce >> log_10_1_1_100.txt\
	&& printf ">    10.1.1b100 SHSH OK...\n" || printf ">    10.2 FAILED. See log.txt!\n"
	../tsschecker -d $MODELID -e $ECID -i 10.1 -s --apnonce $nonce >> log_10_1.txt\
	&& printf ">    10.1 SHSH OK...\n" || printf ">    10.2 FAILED. See log.txt!\n"
	cd ..
done


printf ">\n> If you don't see any errors above, the neccessary files should \n> be saved in ~/shshbackup. Check the log files to be sure. Good luck!\n>\n"



exit


