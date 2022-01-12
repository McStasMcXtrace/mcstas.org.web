Hi there,

This is the basis of the mcstas website at 

https://www.mcstas.org

In this folder there are 

* contents/ - website contents, html files are wrapped in Apache SSI .shtml files by createweb.pl
* layout/ - layout stuff for the page, header.html and footer.html starts/ends each webpage, graphics
* specialcontents/ - "other" webpages, i.e. html/and other stuff not to be parsed by createweb.pl,
                    but to be copied directly to the webserver's DocumentRoot

