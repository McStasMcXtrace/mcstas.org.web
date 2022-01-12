#!/usr/bin/perl
################################################################################
# by Hallmann Web Design 2003                                                  #
#                                                                              #
# Download Manager V1.00 © 2003                                                #
# http://www.themusicpages.com/HWD	                                       #
# Developed by Frank Hallmann.                                                 #
# This software is FREEWARE as long as you leave this header in place!         #
# Do with it as you wish. It is yours to share and enjoy.                      #
# Modify it, improve it, and have fun with it!                                 #
# There are no warranties!!!                                                   #
# Use at your own risk.                                                        #
# The developer can not be held responsible for any loss, damage or harm to any#
# data or system!                                                              #
# Selling the code for this program without prior written consent is           #
# expressly forbidden.  In other words, please ask first before you try and    #
# make money off of my program.                                                #
# By installing the software you agree to the above.                           #
# ALWAYS BACK UP YOUR SYSTEM BEFORE INSTALLING ANY SCRIPT OR PROGRAM FROM ANY  #
# SOURCE!                                                                      #
################################################################################

 require "${root}dwnld.cfg";                    # all config data
 require "${root}cookie.pl";                    # set and get cookie

  &decode_vars;   # get the variables from the browser
  &read_database; # read the database and see if it can find the ID

  if ($idFound)
  {  #ID found
     &read_logfile;  #read the log file and see how many times IP has downloaded file today
     if (&CheckIfBanned)  # check if users's  IP is a banned IP
     {
        $message = "You are not allowed to download this program.";
        $CustomMessage1 = "";
        $CustomMessage2 = "";
        $command = "";
        &print_page($message,$command,$CustomMessage1,$CustomMessage2);  # output the page
     }

     $CookieName = $name;
     $CookieName =~ s/ /_/g;
     &GetCookies($CookieName);   # get the CookieCounter
     $CookieValue = $Cookies{$CookieName};
     @CookieData = split(/\s*\|\s*/,$CookieValue , );
     $CookieCounter = $CookieData[0];
     $CookieDate = $CookieData[1];
     if ($CookieDate ne $today_date)
     {
     	$CookieCounter = 0;
     }
     $CookieCounter++;

     if (($exists < $max_downloads) && ($CookieCounter <= $max_downloads))
     {
      &write_logfile;  # update the log file
      &write_database; # update the counter 

      $CookieValue = $CookieCounter . "|" . $today_date;
      $CookieExpires= "Sun, 21-Jun-2020 12:00:00 GMT";
      SetCookieExpDate($CookieExpires);
      &SetCookies($CookieName,$CookieValue);  # set the CookieCounter

      if ($fields{'action'} eq "redirect")
      {
      	print "Location: $file_name\n\n";
      	exit;
      }
      else
      {
      	$CustomMessage1 = $message1;
        $CustomMessage2 = "";
        $message = "$name is currently downloading.<br>If the download does not begin automatically within $RefreshTimer seconds, please <a href=\"$DownloadScript?action=redirect&id=$fields{'id'}\" $class>click here.</a>";
        $command = "<meta http-equiv=\"refresh\" content=\"$RefreshTimer; url=$file_name\">";
        &print_page($message,$command,$CustomMessage1,$CustomMessage2);  # output the page and start the download
      }
     }
     else
     {
       $CustomMessage1 = "";
       $CustomMessage2 = $message2;
       $command = "";
       $message = "You can download $name only $max_downloads times a day.";
       &print_page($message,$command,$CustomMessage1,$CustomMessage2); # output the page
     }
     exit;
   }
   else
   { #ID not found
     $CustomMessage1 = "";
     $CustomMessage2 = "";
     $command = "";
     $message = "The program you are trying to download could not be found.";
     &print_page($message,$command,$CustomMessage1,$CustomMessage2);
   }
   exit;

sub print_page    # print the page based on the template
{
  ($message,$command,$CustomeMessage1,$CustomMessage2) = @_;
  $added = 0;
  $command_replace = "<meta http-equiv";
  print "Content-type: text/html\n\n";
  if ($TemplateFile eq "") {$TemplateFile = $TemplateFiles[0];}
  open(DATA,"$TemplateFile") || print "<center><font color=red>Error: Could not open template file ($!).</font><br></center>";
  @filecontent = <DATA>;
  close(DATA);

  
  foreach $line(@filecontent)
  {
    chomp($line);
    $BookmarkTag = "bookmark";
    $Message1Tag = "message1";
    $Message2Tag = "message2";

    if ($line =~ /\b$BookmarkTag/i)
    {
      $line = $message;
    }
    elsif ($line =~ /\b$Message1Tag/i)
    {
      $line = $CustomMessage1;
    }
    elsif ($line =~ /\b$Message2Tag/i)
    {
      $line = $CustomMessage2;
    }
    elsif (($line =~ m/$command_replace/i) && (!$added))
    {
      print "$line\n";
      $line = $command;
      $added = 1;
    }
    print "$line\n";
  }
}

# read the database with the information
sub read_database
{
  $idFound = 0;
  open (DATABASE, "<${root}$database");# or print $!;
  if($flocking) {flock DATABASE, 2;}
  @rows = <DATABASE>;
  if($flocking) {flock DATABASE, 8;}
  close DATABASE;
  foreach $thisrow(@rows)
  {
    if ($thisrow =~ m/^$fields{'id'}\|(.*)/)
    {
      @filedata = split(/\s*\|\s*/,$thisrow , );
      $file_id = $filedata[0];
      $file_name = &CleanString($filedata[1]);
      $name = &CleanString($filedata[2]);
      $max_downloads = &CleanString($filedata[3]);
      $message1 = &CleanString($filedata[5]);
      $message2 = &CleanString($filedata[6]);
      $TemplateFile = &CleanString($filedata[7]);
      if ($TemplateFile eq "") {$TemplateFile = $TemplateFiles[0];}
      $idFound = 1;
    }
  }
}

# write back the counter + 1
sub write_database
{
  open (DATABASE, "<${root}$database");# or print $!;
  if($flocking) {flock DATABASE, 2;}
  @rows = <DATABASE>;
  if($flocking) {flock DATABASE, 8;}
  close DATABASE;

 # write back to database and modify counter
  open (DATABASE, ">${root}$database");# or print $!;
  if($flocking) {flock DATABASE, 2;}
  foreach $thisrow(@rows)
  {
    if (!($thisrow =~ m/^$fields{'id'}\|.*/))
    {
      print DATABASE $thisrow;
    }
    else
    {
      chomp $thisrow;
      @filedata = split(/\s*\|\s*/,$thisrow , );
      $file_id = $filedata[0];
      $file_name = $filedata[1];
      $name = $filedata[2];
      $max_downloads = $filedata[3];
      $counter = $filedata[4];
      $counter = $counter + 1;
      $message1 = $filedata[5];
      $message2 = $filedata[6];
      $TemplateFile = $filedata[7];
      if ($TemplateFile eq "") {$TemplateFile = $TemplateFiles[0];}

      $thisrow = $file_id . "|" . $file_name . "|" . $name . "|" .  $max_downloads . "|" . $counter . "|" . $message1 . "|" . $message2 . "|" . $TemplateFile . "\n";
      print DATABASE $thisrow;
    }
  }
  if($flocking) {flock DATABASE, 8;}
  close DATABASE;
}

# check if users's IP is banned from downloading
sub CheckIfBanned
{  
  $ip=$ENV{'REMOTE_ADDR'};
  $IPBanned = 0;
  foreach $ThisIP(@BannedIP)
  {
    if ($ThisIP eq $ip)
    {
      $IPBanned = 1;
    }
  }
  return "$IPBanned";
}

# read the log file and count how many times same IP has downloaded the same file on that day
sub read_logfile
{
  $exists = 0;
  &get_date;
  $ip=$ENV{'REMOTE_ADDR'};
  open (DATABASE, "<${root}$logfile");# or print $!;
  if($flocking) {flock DATABASE, 2;}
  @rows = <DATABASE>;
  if($flocking) {flock DATABASE, 8;}
  close DATABASE;

  foreach $thisrow(@rows)
  {
    if ($thisrow =~ m/^$ip\|.*/)
    {
      @tabledata = split(/\s*\|\s*/,$thisrow , );
      if (($today_date eq $tabledata[1]) && ($fields{'id'} == $tabledata[4]))
      {
        $exists++;
      }
    }
  }
}

# update the logfile
sub write_logfile
{
  &get_date;
  $refer=$ENV{'HTTP_REFERER'};
  $ip=$ENV{'REMOTE_ADDR'};
  if ($refer eq "") {$refer = "no refer";}
  $NewData = $ip . "|" . $today_date . "|" . $the_time . "|" . $refer . "|" . "$fields{'id'}";

  open (DATABASE, ">>${root}$logfile");# or print $!;
  if($flocking) {flock DATABASE, 2;}
  print DATABASE $NewData;
  print DATABASE "\n";
  if($flocking) {flock DATABASE, 8;}
  close DATABASE;
}

# get today's date
sub get_date
{
  ($sek, $min, $std, $day, $mon, $year) = localtime(time);
  $year = $year + 1900;
  $mon = $mon + 1;

  if (length($mon) == 1) {$mon = "0" . $mon;}
  if (length($day) == 1) {$day = "0" . $day;}

  $today_date = "$mon-$day-$year";

  if (length($min) == 1) {$min = "0" . $min;}
  if (length($sek) == 1) {$sek = "0" . $sek;}

  $the_time =  "$std:$min:$sek";
}

# get the variables from the browser
sub decode_vars
 {
  read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
  if (length($buffer) < 5) 
  {
    $buffer = $ENV{QUERY_STRING};
  }

  @pairs = split(/&/, $buffer);
  foreach $pair (@pairs) 
  {
    ($name, $value) = split(/=/, $pair);

    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
    $fields{$name} = $value;
  }
}
  
# clean the string (for displaying)
sub CleanString
{
  ($string) = @_;
  chomp $string;
  $string =~ s/\<pipe>/|/g;
  return "$string";
}
