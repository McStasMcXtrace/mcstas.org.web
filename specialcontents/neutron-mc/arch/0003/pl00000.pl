#! /usr/bin/perl -w

use FileHandle;
$sim_def = $ARGV[0];
foreach $arg (@ARGV)
{
	if ($arg =~ /^instr=/) 
	{
		$sim_def = $arg;
		$sim_def =~ s/^instr=//;
	}
}
#print "Instrument $sim_def, ";
$file  = $sim_def . ".par";
$instr = $sim_def . ".instr";
open(INSTRUMENT, $instr) ;
@lines = <INSTRUMENT>;
close(INSTRUMENT);
#print "Description $instr\n";
$flag = 0;
$string = "";
foreach $line (@lines)
{
	if ($line =~ /^DEFINE/ && $line =~ /INSTRUMENT/) 
	{
		$flag = 1;
	}
	if ($line =~ /^DECLARE/ || $line =~ /^INITIALIZE/ || $line =~ /^TRACE/ || $line
 =~ /^FINALLY/) 
	{
		$flag = 0;
	}
	if ($flag == 1)
	{
		$string = $string . $line ;
	}
}
$line = $string;
$line =~ s/DEFINE//;
$line =~ s/INSTRUMENT//;
$line =~ s/\/\*[.\n]+\*\///g;
@definition = split(/\(/, $line) ;
$instrument =  $definition[0];
$instrument =~ s/\s//g;
#print "Instrument Definition $instrument\n";
$line = $definition[1];
$line =~ s/\)//g;
$line =~ s/\s//g;
$line =~ s/ //g;
$line =~ s/\n//g;
#print "Needed parameters: $line.\n";
@parameters = split(/,/, $line) ;
push(@files,$file);
foreach $arg (@ARGV)
{
	if ($arg =~ /^-p/) 
	{
		$file = $arg;
		$file =~ s/^-p//;
		push(@files, $file) ;
	}
	if ($arg =~ /^par=/) 
	{
		$file = $arg;
		$file =~ s/^par=//;
		push(@files, $file) ;
	}
}
foreach $file (@files)
{
	print "Parameterfile: $file\n";
	open(PARAMETERS, $file) ;
	@lines = <PARAMETERS>;
	close(PARAMETERS);
	foreach $buffer(@lines)
	{
		if ($buffer !~ /^#/)
		{
			$buffer =~ tr/ /\n/;
			$buffer =~ tr/+/\n/;
			$buffer =~ tr/\t/\n/;
			$buffer =~ tr/&/\n/;
			$buffer =~ tr/;/\n/;
			$buffer =~ tr/,/\n/;
			@pairs = split(/\n+/, $buffer) ;
			foreach (@pairs)
			{
				$name=" ";
				($name,$value) =  split(/=/) ;
				$value =~ s/\s//g;
				$name =~ s/\s//g;
				$flag = 0;
				$flag = 1 if (defined $FORM{$name} && $FORM{$name} != $value)  ;
				print "$name:$FORM{$name}=>" if ($flag == 1);  
				$FORM{$name} = $value ;
				#print "$name=$value,";
				print "$FORM{$name}, " if ($flag == 1) ; 
			}
		}
	}
}
print "\n"
foreach $arg (@ARGV)
{
	if ($arg !~ /^-/) 
	{
		($name,$value) =  split(/=/,$arg) ;
		if (defined $value)
		{
			$value =~ s/\s//g;
			$name =~ s/\s//g;
			$name =~ s/ //g;
			$FORM{$name} = $value ;
			#print "$name=$value=$FORM{$name}.\n";
		}
	}
}
$arguments=$sim_def.".stdin";
open (ARGUMENTS, ">$arguments");
open (PARAMETERS, ">>$file") ;
$flag = 0;
foreach $parameter (@parameters)
{
	$parameter =~ s/ //g;
	print "$parameter=";
	print "$FORM{$parameter} " if (defined $FORM{$parameter});
	unless (defined $FORM{$parameter})
	{
		$FORM{$parameter} = <STDIN>;
		$FORM{$parameter}=~ s/[^0-9eE\-.+]//g; 
		$print=$parameter."=".$FORM{$parameter};
		$print =~ s/ //g;
		print PARAMETERS " $print";
	}
	print ARGUMENTS "\n" if ($flag == 1);
	$flag = 1;
	print ARGUMENTS "$FORM{$parameter}";
}
close(PARAMETERS);
close (ARGUMENTS);
foreach $arg (@ARGV)
{
	if ($arg !~ /^-p/ && $arg !~ /^--par/ && $arg =~ /^-/) 
	{
		push(@options, $arg) ;
	}
}
push(@command, $sim_def, @options);
$shell= $sim_def.".sh";
open (SHELL, ">$shell");
$output= $sim_def.".stdout";
print SHELL "mcrun @command < $arguments > $output";
print "Running mcrun @command  < $arguments > $output\n";
close (SHELL);
system 'sh',$shell;
open (OUTPUT, $output);
@lines = <OUTPUT>;
close (OUTPUT);
foreach $line (@lines)
{
	if ($line !~ /Set value of instrument/) 
	{
		print $line;
	}
}


