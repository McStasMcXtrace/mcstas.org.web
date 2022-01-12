#!/usr/bin/perl -w
#
# createweb.pl
#
# version 0.99 + CVS version
# 
# Creates website from a directory structure
#
# originaly made by pmm 20000705
# moved to cvs 20011219
#
# $Log: createweb.pl,v $
# Revision 1.2  2006-12-14 19:15:49  pkwi
# Updated look for the website...
#
# Revision 1.1.1.1  2004/06/22 12:04:08  pkwi
# Import of website
#
# Revision 1.6  2002/01/10 10:29:30  willend
# Tilføjet mellemrum uden betydning - CVS test
#
# Revision 1.5  2001/12/20 10:50:45  kneth
# Log added
#
# 
$VERBOSE = "";

&getenv();
&makeweb();
&scontoweb();
&layouttoweb();
&contoweb();
&makelists();
&makemenu();

sub getenv {
#
# Get environment "con", "scon", "web", "layout" and "prefix"
#

    if ($VERBOSE) {

    print <<"EOF";

Options required:  
  -c contentsdir
  -s specialcontentsdir
  -l layoutdir 
  -w websitedir
  -p URL prefix

------------------------------
EOF
}

    use Getopt::Std;
    getopts('c:s:w:l:p:') or die("You did not specify the right options: $!\n");
    
    unless (defined($opt_c) and defined ($opt_s) and defined($opt_w) 
	    and defined ($opt_l) and defined ($opt_p)) { 
	die "Not all options specified \n"; 
    }
    
    use Cwd;
    $cwd = cwd();
    
    if ($opt_c =~ m|^/|) {
	$con = $opt_c;
    } else {
	$con = "$cwd/$opt_c";
    }

    if ($opt_s =~ m|^/|) {
	$scon = $opt_s;
    } else {
	$scon = "$cwd/$opt_s";
    }
    
    if ($opt_l =~ m|^/|) {
	$layout = $opt_l;
    } else {
	$layout = "$cwd/$opt_l";
    }

    if ($opt_w =~ m|^/|) {
	$web = $opt_w;
    } else {
	$web = "$cwd/$opt_w";
    }
    
    $prefix = $opt_p;
    
    if ($VERBOSE) {
    print <<"EOF";

Options specified:  
  -c $con
  -s $scon
  -l $layout
  -w $web
  -p $prefix

------------------------------

EOF
}

    unless (-d $con and -r $con) {
	die("Unable to read dir $con: $!\n");
    }
    
    unless (-d $scon and -r $scon) {
	die("Unable to read dir $scon: $!\n");
    }
    
    unless (-d $layout and -r $layout) {
	die("Unable to read dir $layout: $!\n");
    }

    if (-e $web) {
	die("Directory must not exist, $web: $!\n");
    }
}

sub makeweb {
#
# Make "web"
#

    mkdir($web, 0777) or die("Unable to mkdir $web: $!\n");
}

sub scontoweb {
#
# Copy structure from "scon" to "web" via links
#

    chdir($scon) or die("Unable to enter dir $scon: $!\n");
    opendir(SCON, ".") or die("Unable to open $scon: $!\n");
    my @names = readdir(SCON) or die("Unable to read $scon: $!\n");
    closedir(SCON);
    chdir($cwd) or die("Unable to chage to dir $cwd: $!\n");
    
    foreach my $name (@names) {
	next if ($name eq ".");
	next if ($name eq "..");
	
	if (-d "$scon/$name" and $name !~ m|CVS|) {
	    system("ln -s $VERBOSE $scon/$name $web/$name");
	    next;
	}
    }
}

sub layouttoweb {
#
# Copy structure from "layout" to "web" via links
#
    
    chdir($layout) or die("Unable to enter dir $layout: $!\n");
    opendir(LAYOUT, ".") or die("Unable to open $layout: $!\n");
    my @names = readdir(LAYOUT) or die("Unable to read $layout: $!\n");
    closedir(LAYOUT);
    chdir($cwd) or die("Unable to chage to dir $cwd: $!\n");
    
    foreach my $name (@names) {
	next if ($name eq ".");
	next if ($name eq "..");
	
	if (-f "$layout/$name") {
	    system("cp $VERBOSE $layout/$name $web/$name");
	    next;
	}
    }
}


sub contoweb {
#
# Copy structure from "con" to "web" via directories
#
    
    sub scancon {
	my ($workdir) = shift;
	
	my ($startdir) = cwd();
	
	chdir($workdir) or die("Unable to enter dir $workdir: $!\n");
	opendir(DIR, ".") or die("Unable to open $workdir: $!\n");
	my @names = readdir(DIR) or die("Unable to read $workdir: $!\n");
	closedir(DIR);
	
	foreach my $name (@names) {
	    next if ($name eq ".");
	    next if ($name eq "..");
	    
	    if (-d $name and not -l $name) {
		my $fullname = "$workdir/$name";
		$fullname =~ s|$con/||;

		next if ($fullname =~ m|CVS|);

		if ($VERBOSE) {print "mkdir $web/$fullname \n";}
		mkdir ("$web/$fullname", 0777) or die("Unable to mkdir $web/$fullname: $! \n");
#		system ("ln -s $VERBOSE $web/$fullname/$name.html $web/$fullname/index.html");
		open(INDEX, ">$web/$fullname/index.html") or die("Unable to write to $web/$fullname/index.html: $!\n");
		print INDEX <<"EOF";
<!--#include virtual="/header.html"-->
<!--#config errmsg="" -->
<!--#include virtual="$name.pure.html"-->
<!--#exec cmd="test -f list.html && cat list.html" -->
<P><DIV align=right><A href="$name.pure.html">Printable version</A></DIV> <HR> <CENTER><SMALL>Last Modified: <!--#flastmod file="$name.pure.html"--></SMALL></CENTER>
<!--#include virtual="/footer.html"-->
EOF
                close INDEX;
	    }

	    if ($name =~ m/\.html\Z/ and -f "$workdir/$name") {
		$htmlweb = "$workdir/$name";
		$htmlweb =~ s|$con|$web|;
		$htmlwebpure = $htmlweb;
		$htmlwebpure =~ s|.html\Z|.pure.html|;
		$htmlwebpurerel = $htmlwebpure;
		$htmlwebpurerel =~ s|$web||; 

		system("cp -a $VERBOSE  $workdir/$name $htmlwebpure");
		open(HTML, ">$htmlweb") or die("Unable to write to $htmlweb: $!\n");
		print HTML <<"EOF";
<!--#include virtual="/header.html"-->
<!--#include virtual="$htmlwebpurerel"-->
<P><DIV align=right><A href="$htmlwebpurerel">Printable version</A></DIV><HR> <CENTER><SMALL>Last Modified: <!--#flastmod virtual="$htmlwebpurerel"--></SMALL></CENTER>
<!--#include virtual="/footer.html"-->
EOF
                close HTML;
	    } elsif (-f $name) {
		$fileweb = "$workdir/$name";
		$fileweb =~ s|$con|$web|;
		system("cp -a $VERBOSE $workdir/$name $fileweb");
	    }

	    if ( -d $name) {
		&scancon("$workdir/$name");
	    }

	    next

	} 
	chdir($startdir) or die("Unable to chage to dir $startdir: $!\n");
    }

&scancon($con);
system("cd $web && ln -s $VERBOSE main.html index.html");
}

sub makemenu {
#
#  Scan "web" for dirs, make menu structure, takeing "hide" 
#  and "priority" into account.
#

# make priority sort, bigger priorities are listed in the top
sub priority {
    if (open (A,"<$con/$a/priority")) {
	while (<A>) {
	    if (/\d*/) {
		$prioritya = $_;  
		chomp($prioritya);
#		print "pri: $a :$prioritya: \n";
	    }
	}
	close A;
    } else {
	$prioritya = 0;  
    }
    if (open (B,"<$con/$b/priority")) {
	while (<B>) {
	    if (/\d*/) {
		$priorityb = $_;  
		chomp($priorityb);
#		print "pri: $b :$priorityb: \n";		
	    }
	}
	close B;
    } else {
	$priorityb = 0;  
    }
#    print "pri: $a, $b:", (($prioritya <=> $priorityb) or ($a cmp $b)), "\n";
    return (($priorityb <=> $prioritya) or ($a cmp $b));
}


# make priority sort, bigger priorities are listed in the top
sub priority2 {
    my ($workdir) = cwd();
    if (open (A,"<$workdir/$a/priority")) {
        while (<A>) {
            if (/\d*/) {
                $prioritya = $_;  
                chomp($prioritya);
#              print "pri: $a :$prioritya: \n";
            }
        }
        close A;
    } else {
        $prioritya = 0;  
    }
    if (open (B,"<$workdir/$b/priority")) {
        while (<B>) {
            if (/\d*/) {
                $priorityb = $_;  
                chomp($priorityb);
#               print "pri: $b :$priorityb: \n";                
            }
        }
        close B;
    } else {
        $priorityb = 0;  
    }
#    print "pri: $a, $b:", (($prioritya <=> $priorityb) or ($a cmp $b)), "\n";
    return (($priorityb <=> $prioritya) or ($a cmp $b));
}


# make secondlevel menus
sub makesubmenu {
    my ($workdir) = shift;
    
    my ($startdir) = cwd();
	
    chdir($workdir) or die("Unable to enter dir $workdir: $!\n");
    opendir(WEB, ".") or die("Unable to open $workdir: $!\n");
    my @names = readdir(WEB) or die("Unable to read $workdir: $!\n");
    closedir(WEB);
    
    foreach my $name (sort priority2 @names) {
	next if ($name eq ".");
	next if ($name eq "..");
	
	unless (-d "$workdir/$name" and not -l "$workdir/$name") {
	    next;
	}
	
        if ($name eq "CVS") {
            next;
        }

	if (-f "$workdir/$name/hide") {
	    next;
	}

	open MENU, ">>$web/menu.html";
    
	if (-f "$workdir/$name/siteonly") {
	    if (open (S,"<$workdir/$name/siteonly")) {
		while (<S>) {
		    $site = $_;
		    print MENU $site;
		}
		close S;
	    }
	}

	my $fullname = "$workdir/$name";
	$fullname =~ s|$con||;
        
        if (-f "$workdir/$name/name") {
	  if (open (S,"<$workdir/$name/name")) {
		while (<S>) {
		$myname=$_;
	     }
		close S;
		chomp($myname);
	   }
	 } else {
	     $myname=$name;
	 }
	

	print MENU "\t\t", '&nbsp;<A href="', $fullname, '" class="menu">', ucfirst $myname, '</A><BR>', "\n";
	
	if (-f "$workdir/$name/siteonly") {
	    print MENU '<!--#endif -->', "\n";
	}

	close MENU;
	
	next;
    }
    chdir($startdir) or die("Unable to chage to dir $startdir: $!\n");
}

# make first level menus
chdir($con) or die("Unable to enter dir $con: $!\n");
opendir(WEB, ".") or die("Unable to open $con: $!\n");
my @names = readdir(WEB) or die("Unable to read $con: $!\n");
closedir(WEB);
chdir($cwd) or die("Unable to chage to dir $cwd: $!\n");

open MENU, ">>$web/menu.html";
print MENU '<P style="font-family:Verdana"><B><A href="/" class="menu">McStas</A></B><BR>', 
    " \n\t", '<SMALL>', "\n";
close MENU;

foreach my $name (sort priority @names) {
    next if ($name eq ".");
    next if ($name eq "..");

    unless (-d "$con/$name" and not -l "$con/$name") {
	next;
    }

    if ($name eq "CVS") {
	next;
    }

    if (-f "$con/$name/hide") {
	next;
    }
    
    open MENU, ">>$web/menu.html";
    
    if (-f "$con/$name/siteonly") {
	if (open (S,"<$con/$name/siteonly")) {
	    while (<S>) {
		$site = $_;
		print MENU $site;
	    }
	    close S;
	}
    }
    if (-f "$con/$name/name") {
	if (open (S,"<$con/$name/name")) {
	    while (<S>) {
		$myname = $_;
	    }
	    close S;
	    chomp($myname);
	}
    } else {
	$myname=$name;
    }


    print MENU '<P style="font-family:Verdana"><B><A href="/', $name,
	'/" class="menu">', ucfirst $myname, '</A></B><BR>'," \n\t", '<SMALL>', "\n";
    close MENU;

    &makesubmenu("$con/$name");

    open MENU, ">>$web/menu.html";
    
    print MENU "\t</SMALL>\n</P> \n";

    if (-f "$con/$name/siteonly") {
	print MENU '<!--#endif -->', "\n";
    }
    close MENU;
    
    next;
}
}

# makes lists    
sub makelists {

    sub scanweb {
	my ($workdir) = shift;
	
	my ($startdir) = cwd();
	
	chdir($workdir) or die("Unable to enter dir $workdir: $!\n");
	opendir(DIR, ".") or die("Unable to open $workdir: $!\n");
	my @names = readdir(DIR) or die("Unable to read $workdir: $!\n");
	closedir(DIR);
	
	foreach my $name (sort priority2 @names) {
	    next if ($name eq ".");
	    next if ($name eq "..");

	    if (-d $name and not -l $name) {
		my $fullname = "$workdir/$name";
		$fullname =~ s|$web/||;
		#my $dirs = `find $web/$fullname -type d -maxdepth 1| wc -l | tr -d ' '`;
		#chomp $dirs;
		#my $lastlevel = "0";
		#if ($dirs > "1") {
		#    $lastlevel = "0";
		#} else {
		#    $lastlevel = "1";
		#}
		#if (not $lastlevel) {
		#    open (HEADER,">>$web/$fullname/list.html") or 
		#	die("Unable to open $web/$fullname/list.html: $!\n");
		#    print HEADER "<H2>", ucfirst $fullname, "</H2>\n<UL>\n";
		#    close HEADER;
		#}
		if ($fullname =~ m|/| and not (-f "$web/$fullname/hide" or $fullname =~ m|CVS|)) {
		    open (LIST,">>$workdir/list.html");
		    $contents = "";
		    if (open(TITLE, "<$web/$fullname/$name.pure.html")) {
			while ($line = <TITLE>){
			    chomp $line;
			    $contents .= $line;
			}
		    }
		    close TITLE;
		    # this works, but problems if there are tags inside the h2 tag
		    if ($contents =~ m|.*?\<h\d\>(.*?)\</h\d\>|si ) { 
			print LIST "<li><a href=\"/$fullname/\">$1</a> </li>", "\n";
		    }
		    else {
			print LIST "<li><a href=\"/$fullname\">", ucfirst $name, "</a> </li>", "\n";
		    }
		    close LIST;
		}
		&scanweb("$workdir/$name");
		#if (not $lastlevel) {
		#    open (FOOTER,">>$web/$fullname/list.html") or 
		#	die("Unable to open $web/$fullname/list.html: $!\n");
		#    print FOOTER "</UL>\n <hr> \n";
		#    close FOOTER;
		#}
		next;
	    }
	}
	chdir($startdir) or die("Unable to chage to dir $startdir: $!\n");
    }

&scanweb($web);
}

# --------------------------------
# Schematic overview of the program
# -------------------------------- 
#
# * get environment "con", "scon", "web", "layout" and "prefix"
# * empty "web"
# * copy structure from "scon" to "web" via links
# * copy structure from "layout" to "web" via links
# * copy structure from "con" to "web" via directories
# * copy htmlfiles from "con" to "web" via links
# * make htmlfiles in "web" which includes the layout 
# * scan "web" for dirs with dirs in them, make linklist in "web"
# * scan "web" for dirs, make index.html in "web" including 
#   linklist if eksistent.
# * scan "con" for dirs, make menu structure, takeing "hide" 
#   and "priority" into account.
#
# --------- 
# psudocode
# ---------
#
# &getenv();
#
#   print posible options
#   exit if not all required options given
#   get options
#   make options absolute pathnames
#   print given options
#   check permissions on pathnames
#  
# &makeweb();
#  
#   make "web" directory
#
# &scontoweb();
#
#   make links, ln -s scon/* web/* 
#
# &layouttoweb();
#
#   make links, ln -s layout/* web/* (report clashes)
#
# &contoweb();
#
#   for file in files
#     if file is directory
#       mkdir web/file
#       ln index.html
#
#     if file is *.html
#       ln -s con/*.html web/*.pure.html
#       print >> web/*.html
#         <!--#include virtual="/header.html"-->
#         <!--#if expr="${HTTP_USER_AGENT} = /MSIE/" -->
#           <!--#include virtual="list.html"-->
#         <!--#endif -->
#         <!--#include virtual="/*.pure.html"-->
#         <!--#include virtual="/footer.html"-->
#
#     if file is other file
#       ln -s con/file web/file
#   end
#
# &makelists();
#
#   for file in files
#     if file is directory
#       add entry to parent/list.html including headline 
#           from file/file.pure.html
#       add header to file/list.html 
#       recursive
#       add footer to file/list.html
#   end
#
# &makemenu();
#
#   find 1-level and 2-level directories
#   make entries in "web"/menu.html 
# 
#         
