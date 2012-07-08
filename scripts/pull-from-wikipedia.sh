#!/bin/bash

INF=../data/elpais_lexicalisation_frequency.txt
TMP=../tmp

_q () {
	i=$(echo $1|sed -e 's/ /_/g')
	head='<h1 id="firstHeading" class="firstHeading">'
	raw=$(wget -O - -q http://en.wikipedia.org/wiki/$i|grep "$head"|awk -F'[<>]' '{print $5}')
	if [ "$raw" = "Main Page" ]
	then 
		raw=""
	fi
	echo "$raw"|sed -e '
		s/ /_/g;
		s/(/%28/g;
		s/)/%29/g;
	'
}

_out () {
	echo "<$1> <http://xmlns.com/foaf/0.1/primaryTopic> <http://dbpedia.org/resource/$2> ."
}

_fix () {
	echo $1 | sed -e '
		s/cion_/ción_/;
		s/polit/polít/;
		s/_/ /g;
	'
}

_tr () {
	_fix "$1"|apertium es-en|sed -e 's/ /_/g'|grep -v '\*'
}

cat $INF|awk '{print $2}'|while read raw
do
	i=$(_fix $raw|awk 'BEGIN{FS="/"}{print $5;}')
	trq=$(_tr "$i")
	tr=$(_q "$trq")
	if [ x"$tr" != x"" ]
	then
		_out $raw $tr  >> $TMP/tr.txt
	else
		untr=$(_q "$i")
		if [ x"$untr" != x"" ]
		then
			_out $raw $untr  >> $TMP/untr.txt
		else
			echo $raw >> $TMP/todo.txt
		fi
	fi
done
