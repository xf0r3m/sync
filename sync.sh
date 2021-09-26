#!/bin/bash

server="";
# Użytkownik zdalny
ruser="";
# Ścieżka bezwzględna do katalogu użytkownika zdalnego
rdirectory="";

# Dodatkowe ustawienia SSH, dla RSYNC
#export RSYNC_RSH='ssh ';

# Ścieżka do katalogu lokalnego
ldirectory="";

if [ ! -d "${HOME}/${ldirectory}" ]; then mkdir "${HOME}/${ldirectory}"; fi

function printhelp {

	echo "Skrypt szybkiej synchronizacji katalogu zdalnego";
	echo "morketsmerke.net";
	echo "2021; COPYLEFT; ALL RIGHTS REVERSED";
	echo "";
	echo "push - Przesłanie danych z katalogu lokalnego na katalog zdalny";
	echo "pull - Pobranie zawartości katalogu zdalnego do katalogu lokalnego";
}
if [ ! "$1" ]; then 

	printhelp;
	exit 1;

else
	if [ "$1" = "push" ]; then 
	
		echo "[*] Synchronizacja: local -> remote";
		rsync -avu ${HOME}/${ldirectory}/* ${ruser}@${server}:${rdirectory};

	elif [ "$1" = "pull" ]; then 

		echo "[*] Synchronizacja remote -> local";
		rsync -avu ${ruser}@${server}:${rdirectory}/* ${HOME}/${ldirectory};

	else 
		printhelp;
		exit 1;
	fi

fi
