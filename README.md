Hi there,

This is the basis of the mcstas website at 

http://mcstas.risoe.dk

In this folder there are 

bin/ - scripts to build the website
bin/createweb.pl - perl script, parsing the contents/ specialcontents/ and layout/ folders
                   also builds a menu for the webpage, based on the contents folder and subs

bin/doweb - shell script calling createweb.pl with the proper arguments 
contents/ - website contents, html files are wrapped in Apache SSI .shtml files by createweb.pl
layout/ - layout stuff for the page, header.html and footer.html starts/ends each webpage, graphics
specialcontents/ - "other" webpages, i.e. html/and other stuff not to be parsed by createweb.pl,
                    but to be copied directly to the webserver's DocumentRoot

Besides this, infrastructure has been added to fys-lin-1.risoe.dk to build the website
if the cvs repository has been changed.

For further explanation of what is going on, contact peter.willendrup@risoe.dk or marker@anc.dk
(marker is the original developer of createweb.pl)
