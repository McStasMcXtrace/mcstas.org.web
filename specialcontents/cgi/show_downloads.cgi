#!/usr/bin/perl
################################################################################
# by Hallmann Web Design 2003                                                  #
################################################################################

  require "${root}dwnld.cfg";
  print "Content-type: text/html\n\n";

  &decode_vars;
  &read_database;
  if ($idFound != 0)
  {
    print "document.writeln($counter);\n";
  }
  exit;
  

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
      $file_name = $filedata[1];
      $name = $filedata[2];
      $max_downloads = $filedata[3];
      $counter = $filedata[4];
      $idFound = 1;
    }
  } 
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




