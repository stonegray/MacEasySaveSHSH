# MacEasySaveSHSH

SHSH save script for tsschecker. Downloads and runs @timhstar's tool to grab SHSH for 10.2, 10.1, and both builds of 10.1.1

*Important:* The script has been updated to save nonces. Back up your original blobs and run it again to save them. 

*For 6s+ users:* TSSChecker might try and download the IPSWs for the firmwares, which takes a while. You can also PM me your model and ECID and I'll send you your blobs. You can also make sure the correct firmwares are in `~/Library/iTunes/iPhone Software Updates`

To use: 

- Save into a folder on your Mac.
- Open terminal to the folder. 
- Type `chmod +x shshbackup.sh && ./shshbackup.sh`
- Follow the prompts!
- Check logs after to make sure everything went smoothly

Saves SHSH into ~/shshbackup
