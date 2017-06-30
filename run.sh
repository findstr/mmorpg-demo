#!/bin/bash

getchar()
{

	SAVEDTTY=`stty -g`
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -cbreak
	stty $SAVEDTTY
}

./silly/silly gate.conf &
sleep 1
./silly/silly login.conf&
sleep 1
./silly/silly role.conf&
sleep 1

echo "Please press any to exit"
CH=`getchar`
kill `ps -ef | grep silly | grep -v grep | awk '{print $2}'`
echo "You Press $CH, exit"

