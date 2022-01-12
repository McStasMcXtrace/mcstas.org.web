#!/usr/bin/perl
my $pwd;
my $release = $ARGV[0];

$pwd="/home/mcstas/Builds/checkout/web/contents/documentation/manual/";
opendir(DIR, $pwd);
@files = grep(/\.ps\.gz$|\.pdf$/,readdir(DIR));
@manufiles = grep(/$release-manual/,@files);
@compfiles = grep(/$release-components/,@files);
@manufiles = reverse(@manufiles);
@compfiles = reverse(@compfiles);
@otherfiles = grep(!/$release-manual|$release-components/,@files);
@otherfiles=reverse(@otherfiles);

closedir(DIR);

$url = "/documentation/manual";

system("cat manual.html.top");
system("ln -sf $manufiles[0] $pwd/mcstas-manual.pdf");
system("ln -sf $compfiles[0] $pwd/mcstas-components.pdf");
filetable($url,"McStas user and programmers manual (mcstas-$release)",@manufiles);
filetable($url,"McStas component manual (mcstas-$release)", @compfiles);
print "<hr>\n";
print "</body>\n";
print "</html>\n";


sub filetable {
    my ($url, $title, @files) = @_;
    print "<h2>$title</h2>\n";
    print "<table BORDER COLS=3 width=75%>\n";
    print "<tr>\n";
    print "<td>\n";
    print "<center><b>Filename</b></center\n>";
    print "</td>\n";
    
    print "<td>\n";
    print "<center><b>Size (kByte)</b></center\n>";
    print "</td>\n";
    
    print "<td>\n";
    print "<center><b>Date</b></center>\n";
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
	$size = $size / 1000;
	print "<td>\n";
	printf "<center>%d</center>\n", $size;
	print "</td>\n";
	print "<td>\n";
	print scalar localtime("$mtime");
	print "\n";
	print "</td>\n";
	print "</td>\n";
	print "</tr>\n";
    }
    print "</table>\n";
    
}
