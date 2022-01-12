First create a folder (database) for the database
CHMOD this folder 766
If you can, add a password to this folder

edit the file "dwnld.cfg"

$logfile = "database/statistics.txt";
$database = "database/db.txt";
$IDFile = "database/id.txt";

where "database" is the folder you just created.
Adjust all the other variables to your needs.

Then upload all the scripts in ASCII mode to the directory you want to run the scripts at.
e.g. home/yourdomain/www/cgi-bin
The "database" folder should be at home/yourdomain/www/cgi-bin/database

CHMOD the .cgi and .pl scripts 755, the .cfg and .lib scripts 711.
If you cannot CHMOD 711, change the extension from .lib to .cgi and also change the names in dwnld_admin.cgi

  require "${root}dwnld_admin_templates.lib";  to require "${root}dwnld_admin_templates.cgi";
  and so on...

This is necessary to avoid viewing the files with a browser.

Run dwnld_admin.cgi first. Add a file to the database.
Then run download.cgi

The syntax for this program is download.cgi?id={the number of the file}
e.g. download.cgi?id=0
This will start the download automatically after the set time.

or

to create a clickable link add this:
download.cgi?action=redirect&id={the number of the file}
e.g. download.cgi?action=redirect&id=0

show_downloads.cgi?id={the number of the file}
e.g. show_downloads.cgi?id=0 will display the total number of downloads.
You can call the script out of a HTML file
e.g. <script src="http://www.yourdomain/cgi-bin/show_downloads.cgi?id=0"></script>

The template file for the downloads must include this tag:

<!--bookmark-->

This is where the script inserts text.

The custom messages will be included wherever the following tags are found:
<!--message1-->

and/or

<!--message2-->

Also the template must have a line starting with <meta http-equiv in the head.
e.g. <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
This is where the script will insert the refresh meta tag.

The script is free to use and therefor comes without support.
If you need support or if you need us to install it for you, we offer help on a pay per incident basis.
Contact us for details.

Thank you,
Hallmann Web Design
