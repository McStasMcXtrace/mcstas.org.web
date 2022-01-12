#!/bin/sh

In=$1
Out=$1.html

Ver=`echo ${In} | cut -f2- -dy |cut -f2- -d-|cut -f2- -d0|cut -b2-`

echo "<h1>Suppplental ${Ver} mcdisplay-Python package for McStas 2.0</h1>" > $Out
echo "<p>This is an add-on Python-based mcdisplay package for McStas 2.0 on the platforn ${Ver}." >> $Out
echo "<p>To use it, you will need an x3d-viewer on your system - we recommend <a href=\"http://www.instantreality.org\" target=_blank>Instant Player</a> developed by the Fraunhofer Gesellschaft." >> $Out