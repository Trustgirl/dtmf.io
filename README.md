# This is API bash script for https://dtmf.io
# BTC Donate: 1MocKvtHaYVi7EYWckC7TcYnSZWoj3fzR4 

#  How to install:
     root@localhost# apt-get update; apt-get -y install curl jq unzip wget
     user@localhost$ wget https://github.com/Trustgirl/dtmf.io/archive/master.zip; unzip master.zip

#  How to configure:
    Change token, this is API key
    user@localhost$ nano dtmf.io-master/dtmf.sh
    user@localhost$ cd dtmf.io-master; ./dmtf.sh

     ./dtmf.sh l: list all my numbers
     ./dtmf.sh a: all possible number groups
     ./dtmf.sh r: read sms
     ./dtmf.sh rent: rent a new number
     ./dtmf.sh del: del number
     ./dtmf.sh balance: balance in satoshi
     ./dtmf.sh sendsms from +1234567890 to +7234567890


# Contact
     Email: semitrust@airmail.cc

