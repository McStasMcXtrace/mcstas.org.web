#!/usr/bin/perl
my $pwd;
my $release = $ARGV[0];

$pwd="/home/mcstas/Builds/checkout/web/contents/download/share";
opendir(DIR, $pwd);
@files = readdir(DIR);
@files = grep(!/constructpage.pl|^share|.md5|.html|name|CVS|^\./,@files);

closedir(DIR);

$url = "/download/share";

system("cat share.html.top");
filetable($url,"Useful files",@files);
print "<hr>\n";
print "</body>\n";
print "</html>\n";


sub filetable {
    my ($url, $title, @files) = @_;
    print "<h2>$title</h2>\n";
    print "<table BORDER COLS=5 WIDTH=\"100%\" >\n";
    print "<tr>\n";
    print "<td>\n";
    print "<center><b>Filename</b></center\n>";
    print "</td>\n";
    
    print "<td>\n";
    print "<center><b>Description</b></center>\n";
    print "</td>\n";

    print "<td>\n";
    print "<center><b>Size (kByte)</b></center\n>";
    print "</td>\n";
    
    print "<td>\n";
    print "<center><b>Date</b></center>\n";
    print "</td>\n";
    print "<td>\n";
    print "<center><b>Checksum</b></center>\n";
    print "</td>\n";
    print "</tr>\n";
    

    foreach $file (@files) {
	print "<tr>\n";
	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
	 $atime,$mtime,$ctime,$blksize,$block)
	    = stat "$pwd/$file";
	print "<td>\n";
	printf "<a href=\"$url/%s\">%s</a>\n", $file, $file;
	#print "$file\n";
	print "</td>\n";
	print "<td>\n";
	print "<center><a href=\"$file.html\">Info</a></center>\n";
	print "</td>\n";
	$size = $size / 1000;
	print "<td>\n";
	printf "<center>%d</center>\n", $size;
	print "</td>\n";
	print "<td>\n";
	print scalar localtime("$mtime");
	print "\n";
	print "</td>\n";
	print "</td>\n";
	print "<td>\n";
	system("md5sum $file|cut -f 1 -d\" \" > $file.md5");
	print "<center><a href=\"$file.md5\">md5</a></center>\n";
	print "</td>\n";
	print "</tr>\n";
    }
    print "</table>\n";
    
}
