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
  require "${root}dwnld_admin_templates.lib";    # templates for menus, inputs etc.
  require "${root}dwnld_report_templates.lib";   # error templates, report templates
  require "${root}dwnld_admin_general.lib";      # general things such as checking if logged in...
  require "${root}dwnld_admin_files.lib";        # everything related to files


  $developer = "<font face=\"Verdana, Arial, Helvetica, sans-serif\" size=\"1\">Developed by Hallmann Web Design</font>";
  $title = "Download Manager Admin Tool";

  %ErrorMessages  = ("URL" => "Please enter all of the information required. Missing input: <b>URL</b>",
                    "Name" => "Please enter all of the information required. Missing input: <b>Name</b>",
                    "maxDwnlds" => "Please enter all of the information required. Missing input: <b>Max downloads/day</b>",
                    "maxDwnldsRange" => "The input <b>Max downloads/day</b> must be a number between 1 and $MaxDownload",
                    "ID" => "An error has occurred when adding the record to the database.",
                    "IDNotFound" => "An error has occurred when accessing the record.");

  %ResultMessage = ("AddFile" => "The file has been successfully added to the database.",
                    "ModifyFile" => "The file has been successfully modified.",
                    "DeleteFile" => "The file has been successfully deleted.",
                    "NoStats" => "No statistics available for this file.",
                    "ThisStatsDeleted" => "The statistics for this file have been deleted.",
                    "StatsCleared" => "The statistics have been deleted.",
                    "NoAction" => "The action has been canceled.");

  %cmd = ("logout" => "<form name=\"logout\" method=\"post\" action=\"$ScriptName\"><input type=\"hidden\" name=\"action\" value=\"logout\"><input type=\"submit\" name=\"cmdLogout\" value=\"Logout\"></form>",
          "mainmenu" => "<form name=\"mainmenu\" method=\"post\" action=\"$ScriptName\"><input type=\"submit\" name=\"cmdMainMenu\" value=\"Menu\"></form>",
          "addfile" => "<form name=\"add\" method=\"post\" action=\"$ScriptName\"><input type=\"hidden\" name=\"action\" value=\"AddFile\"><input type=\"submit\" name=\"cmdAdd\" value=\"Add a File\"></form>",
          "modifyfile" => "<form name=\"modify\" method=\"post\" action=\"$ScriptName\"><input type=\"hidden\" name=\"action\" value=\"ModifyFile\"><input type=\"submit\" name=\"cmdModifyFile\" value=\"Modify a File\"></form>",
          "deletefile" => "<form name=\"delete\" method=\"post\" action=\"$ScriptName\"><input type=\"hidden\" name=\"action\" value=\"DeleteFile\"><input type=\"submit\" name=\"cmdDeleteFile\" value=\"Delete a File\"></form>",
          "stats" => "<form name=\"stats\" method=\"post\" action=\"$ScriptName\"><input type=\"hidden\" name=\"action\" value=\"stats\"><input type=\"submit\" name=\"cmdStats\" value=\"View Statistics\"></form>",
          "clearstats" => "<form name=\"clearstats\" method=\"post\" action=\"$ScriptName\"><input type=\"hidden\" name=\"action\" value=\"ClearStats\"><input type=\"submit\" name=\"cmdStats\" value=\"Clear Statistics\"></form>");



################################################################################

  &decode_vars;        # get the action and the vars
  &checkIfLoggedIn;    # checking if logged in

  if ($loggedIn) #main program
  {
     if ($fields{'action'} ne "")
     {
       #Logging out#################################
       if ($fields{'action'} eq "logout")
       {
         &SetCookies($CookieName,"");
         $username = "";
         &print_LogoutPage;
       } 

#Adding a record to the database#################################
       elsif ($fields{'action'} eq "AddFile")  # print AddFile screen
       {
         &print_AddFilePage;
       }
       elsif ($fields{'action'} eq "AddThisFile") #record will be added
       {
       	 # first check all inputs
       	 &check_inputs;

         # now check the ID, must be unique!
         $ID = &get_id;
         $IDUsed = &IsIDUsed($ID); # if ID is already used, add one and have user try again
         if ($IDUsed) {$ID = $ID + 1; &save_id($ID); $error = $ErrorMessages{"ID"}; &print_error($error);}

         # update ID file and add record to database
         &save_id($ID);
         &AddFileToDatabase($ID);
         # report success
         $message = $ResultMessage{"AddFile"}; $message .= "<br>The ID of this file is $ID.<br>The download link is <b>$DownloadScript?id=$ID</b>"; $button = "addfile"; &print_result($message,$button);
       }

#modifying a record in the database#################################
       elsif ($fields{'action'} eq "ModifyFile") #record to be modified, print selection screen
       {
       	 &read_all;  # read all records
       	 $action = "ModifySelectedFile";
       	 $ButtonName = "Modify this File";
         &print_select_screen($action,$ButtonName);
       }
       elsif ($fields{'action'} eq "ModifySelectedFile") #record to be modified, print input screen
       {
       	 $ID = $fields{'ID'};
       	 &read_one($ID);
       	 if ($idFound == 1)
       	 {
       	   &print_ModifyFilePage($file_id,$file_name,$name,$max_downloads,$counter);
       	 }
         else
         {
           $error = $ErrorMessages{"IDNotFound"}; &print_error($error);
         }
       }
       elsif ($fields{'action'} eq "ModifyThisFile") #record to be modified, finaly modify the record
       {
          # first check all inputs
       	 &check_inputs;
         $ID = $fields{'ID'};
         &save_one($ID);  #save the one with the ID
         # report success
         $message = $ResultMessage{"ModifyFile"}; $message .= "<br>The ID of this file is $ID.<br>The download link is <b>$DownloadScript?id=$ID</b>";$button = "modifyfile"; &print_result($message);
       }

#Deleting a record from the database#################################
       elsif ($fields{'action'} eq "DeleteFile")   #record to be deleted, print selection screen
       {
         &read_all;  # read all records
       	 $action = "DeleteSelectedFile";
       	 $ButtonName = "Delete this File";
         &print_select_screen($action,$ButtonName);
       }
       elsif ($fields{'action'} eq "DeleteSelectedFile") #Ask first
       {
         $ActionYes = "DeleteThisSelectedFileYes";
         $ActionNo = "DeleteThisSelectedFileNo";
         $message = "Are you sure you want to delete this file?<br>All statistics about this file will also be deleted!";
         $ID = $fields{'ID'};
         &print_AskQuestion($ActionYes,$ActionNo,$message,$ID);
       }
       elsif ($fields{'action'} eq "DeleteThisSelectedFileYes") #delete the record
       {
         $ID = $fields{'ID'};
         &delete_one($ID);
         &delete_one_stats($ID);
         # report success
         $message = $ResultMessage{"DeleteFile"}; $message .= "<br>The ID of this file <b>($ID)</b> is no longer available.";$button = "deletefile"; &print_result($message);
       }
       elsif ($fields{'action'} eq "DeleteThisSelectedFileNo") #No action
       {
         $message = $ResultMessage{"NoAction"}; $button = "deletefile"; &print_result($message);
       }

#View Statistics#################################
       elsif ($fields{'action'} eq "stats") #statistics
       {
       	 &read_all;  # read all records
       	 $action = "StatsSelectedFile";
       	 $ButtonName = "Show more...";
         &print_select_screen($action,$ButtonName);
       }
       elsif ($fields{'action'} eq "StatsSelectedFile") #statistics
       {
       	$ID = $fields{'ID'};
       	&read_logfile($ID);
       	&print_screen_stats;
       }

       elsif ($fields{'action'} eq "DeleteThisStats") #Ask first
       {
         $ActionYes = "DeleteThisStatsYes";
         $ActionNo = "DeleteThisStatsNo";
         $message = "Are you sure you want to delete the statistics for this file?";
         $ID = $fields{'ID'};
         &print_AskQuestion($ActionYes,$ActionNo,$message,$ID);
       }
       elsif ($fields{'action'} eq "DeleteThisStatsYes") #Delete the stats for this ID
       {
         $ID = $fields{'ID'};
       	 &delete_one_stats($ID);
       	 $message = $ResultMessage{"ThisStatsDeleted"}; $button = "stats"; &print_result($message);
       }
       elsif ($fields{'action'} eq "DeleteThisStatsNo") #No action
       {
         $message = $ResultMessage{"NoAction"}; $button = "stats"; &print_result($message);
       }

#Delete the statistics file#################################
       elsif ($fields{'action'} eq "ClearStats") #Ask first
       {
         $ActionYes = "ClearStatsYes";
         $ActionNo = "ClearStatsNo";
         $message = "Are you sure you want to delete all statistics?";
         $ID = $fields{'ID'};
         &print_AskQuestion($ActionYes,$ActionNo,$message,$ID);
       }
       elsif ($fields{'action'} eq "ClearStatsYes") #Clear the Statistics file
       {
       	 &delete_all_stats;
       	 $message = $ResultMessage{"StatsCleared"}; $button = ""; &print_result($message);
       }
       elsif ($fields{'action'} eq "ClearStatsNo") #No action
       {
         $message = $ResultMessage{"NoAction"}; $button = ""; &print_result($message);
       }
     }

     # no action will display the main menu
     &print_MainMenuPage;

  }
  else  #$loggedIn == 0
  {        
    &SetCookies($CookieName,"");
    $username = "";
    &print_LoginPage;
  }

  exit;



