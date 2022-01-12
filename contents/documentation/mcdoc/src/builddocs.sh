#! /bin/sh

SRCLIST="http://www.ill.fr/tas/mcstas/src/ http://neutron.risoe.dk/documentation/mcdoc/src/risoe/"
DIRLIST="sources optics samples monitors misc"
MCDOC="http://neutron.risoe.dk/documentation/mcdoc/src/risoe/mcdoc.pl"

for d in $DIRLIST
do
    rm -Rf $d
    mkdir $d
    for src in $SRCLIST
    do
	(cd $d; wget -q -nd -L -A comp,cmp,com -r $src/$d/; rm -f index.html)
    done
done

rm -f mcdoc.pl
wget -q -nd -L $MCDOC
chmod u+x mcdoc.pl
./mcdoc.pl
