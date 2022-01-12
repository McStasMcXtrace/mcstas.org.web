##############################################################################
# HTTP Cookie Library           Version 2.1                                  #
# Copyright 1996 Matt Wright    mattw@worldwidemart.com                      #
# Created 07/14/96              Last Modified 12/23/96                       #
# Script Archive at:            http://www.worldwidemart.com/scripts/        #
#                               Extensive Documentation found in README file.#
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 1996 Matthew M. Wright.  All Rights Reserved.                    #
#                                                                            #
# HTTP Cookie Library may be used and modified free of charge by anyone so   #
# long as this copyright notice and the comments above remain intact.  By    #
# using this code you agree to indemnify Matthew M. Wright from any          #
# liability that might arise from it's use.                                  #
#                                                                            #
# Selling the code for this program without prior written consent is         #
# expressly forbidden.  In other words, please ask first before you try and  #
# make money off of my program.                                              #
#                                                                            #
# Obtain permission before redistributing this software over the Internet or #
# in any other medium.  In all cases copyright and header must remain intact.#
##############################################################################
# Define variables for this library.                                         #

    # This is an optional variable.  If not defined, the cookie will expire  #
    # when a user's session ends.                                            #
    # Should be defined as: Wdy, DD-Mon-YYYY HH:MM:SS GMT                    #

$Cookie_Exp_Date = '';

    # By default this will be set to the same path as the document being     #
    # described by the header which contains the cookie.                     #

$Cookie_Path = '';

    # By default this will be set to the domain host name of the server      #
    # which generated the cookie response.                                   #

$Cookie_Domain = '';

    # This should be set to 0 if the cookie is safe to send across over      #
    # unsecured channels.  If set to 1 the cookie will only be transferred   #
    # if the communications channel with the host is a secure one. Currently #
    # this means that secure cookies will only be sent to HTTPS (HTTP over   #
    # SSL) servers.  According to Netscape docs at least.                    #

$Secure_Cookie = '0';

    # These are the characters which the HTTP Cookie Library will translate  #
    # to url encoded (hex characters) when it sets individual or compressed  #
    # cookies.  The array holds the order in which these should be           #
    # translated (as we wouldn't want to translate spaces into pluses and    #
    # then pluses into the URL encoded form, but rather the other way        #
    # around) and the associative array holds the values to translate        #
    # characters into.  The decoded set will reverse the process.  Feel free #
    # to add any other characters here, but it shouldn't be necessary.       #
    # This is a correction in version 2.1 which makes this library adhere    #
    # more to the Netscape specifications.                                   #

@Cookie_Encode_Chars = ('\%', '\+', '\;', '\,', '\=', '\&', '\:\:', '\s');

%Cookie_Encode_Chars = ('\%',   '%25',
                        '\+',   '%2B',
                        '\;',   '%3B',
                        '\,',   '%2C',
                        '\=',   '%3D',
                        '\&',   '%26',
                        '\:\:', '%3A%3A',
                        '\s',   '+');

@Cookie_Decode_Chars = ('\+', '\%3A\%3A', '\%26', '\%3D', '\%2C', '\%3B', '\%2B', '\%25');

%Cookie_Decode_Chars = ('\+',       ' ',
                        '\%3A\%3A', '::',
                        '\%26',     '&',
                        '\%3D',     '=',
                        '\%2C',     ',',
                        '\%3B',     ';',
                        '\%2B',     '+',
                        '\%25',     '%');
# Done                                                                       #
##############################################################################

##############################################################################
# Subroutine:    &GetCookies()                                               #
# Description:   This subroutine can be called with or without arguments. If #
#                arguments are specified, only cookies with names matching   #
#                those specified will be set in %Cookies.  Otherwise, all    #
#                cookies sent to this script will be set in %Cookies.        #
# Usage:         &GetCookies([cookie_names])                                 #
# Variables:     cookie_names - These are optional (depicted with []) and    #
#                               specify the names of cookies you wish to set.#
#                               Can also be called with an array of names.   #
#                               Ex. 'name1','name2'                          #
# Returns:       1 - If successful and at least one cookie is retrieved.     #
#                0 - If no cookies are retrieved.                            #
##############################################################################

sub GetCookies {

    # Localize the variables and read in the cookies they wish to have       #
    # returned.                                                              #

    local(@ReturnCookies) = @_;
    local($cookie_flag) = 0;
    local($cookie,$value);

    # If the HTTP_COOKIE environment variable has been set by the call to    #
    # this script, meaning the browser sent some cookies to us, continue.    #

    if ($ENV{'HTTP_COOKIE'}) {

        # If specific cookies have have been requested, meaning the          #
        # @ReturnCookies array is not empty, proceed.                        #

        if ($ReturnCookies[0] ne '') {

            # For each cookie sent to us:                                    #

            foreach (split(/; /,$ENV{'HTTP_COOKIE'})) {

                # Split the cookie name and value pairs, separated by '='.   #

                ($cookie,$value) = split(/=/);

                # Decode any URL encoding which was done when the compressed #
                # cookie was set.                                            #

                foreach $char (@Cookie_Decode_Chars) {
                    $cookie =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                    $value =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                }

                # For each cookie to be returned in the @ReturnCookies array:#

                foreach $ReturnCookie (@ReturnCookies) {

                    # If the $ReturnCookie is equal to the current cookie we #
                    # are analyzing, set the cookie name in the %Cookies     #
                    # associative array equal to the cookie value and set    #
                    # the cookie flag to a true value.                       #

                    if ($ReturnCookie eq $cookie) {
                        $Cookies{$cookie} = $value;
                        $cookie_flag = "1";
                    }
                }
            }

        }

        # Otherwise, if no specific cookies have been requested, obtain all  #
        # cookied and place them in the %Cookies associative array.          #

        else {

            # For each cookie that was sent to us by the browser, split the  #
            # cookie name and value pairs and set the cookie name key in the #
            # associative array %Cookies equal to the value of that cookie.  #
            # Also set the coxokie flag to 1, since we set some cookies.      #

            foreach (split(/; /,$ENV{'HTTP_COOKIE'})) {
                ($cookie,$value) = split(/=/);

                # Decode any URL encoding which was done when the compressed #
                # cookie was set.                                            #

                foreach $char (@Cookie_Decode_Chars) {
                    $cookie =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                    $value =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                }

                $Cookies{$cookie} = $value;
            }
            $cookie_flag = 1;
        }
    }

    # Return the value of the $cookie_flag, true or false, to indicate       #
    # whether we succeded in reading in a cookie value or not.               #

    return $cookie_flag;
}

##############################################################################
# Subroutine:    &SetCookieExpDate()                                         #
# Description:   Sets the expiration date for the cookie.                    #
# Usage:         &SetCookieExpDate('date')                                   #
# Variables:     date - The date you wish for the cookie to expire, in the   #
#                       format: Wdy, DD-Mon-YYYY HH:MM:SS GMT                #
#                       Ex. 'Wed, 09-Nov-1999 00:00:00 GMT'                  #
# Returns:       1 - If successful and date passes regular expression check  #
#                    for format errors and the new ExpDate is set.           #
#                0 - If new ExpDate was not set.  Check format of date.      #
##############################################################################

sub SetCookieExpDate {

    # If the date string is formatted as: Wdy, DD-Mon-YYYY HH:MM:SS GMT, set #
    # the $Cookie_Exp_Date to the new value and return 1 to signal success.  #
    # Otherwise, return 0, as the date was not successfully changed.         #
    # The date can also be set null value by calling: SetCookieExpDate('').  #

    if ($_[0] =~ /^\w{3}\,\s\d{2}\-\w{3}-\d{4}\s\d{2}\:\d{2}\:\d{2}\sGMT$/ ||
        $_[0] eq '') {
        $Cookie_Exp_Date = $_[0];
        return 1;
    }
    else {
        return 0;
    }
}

##############################################################################
# Subroutine:    &SetCookiePath()                                            #
# Description:   Sets the path for the cookie to be sent to.                 #
# Usage:         &SetCookiePath('path')                                      #
# Variables:     path - The path to which this cookie should be sent.        #
#                       Ex. '/' or '/path/to/file'                           #
# Returns:       Nothing.                                                    #
##############################################################################

sub SetCookiePath {

    # Set the new Cookie Path, assuming it is correct.  No error checking is #
    # done.                                                                  #

    $Cookie_Path = $_[0];
}

##############################################################################
# Subroutine:    &SetCookieDomain()                                          #
# Description:   Sets the domain for the cookie to be sent to.  You can only #
#                specify a domain within the current domain.  Must have 2 or #
#                3 periods, depending on type of domain. e.g., .domain.com   #
#                or .k12.co.us.                                              #
# Usage:         &SetCookieDomain('domain')                                  #
# Variables:     domain - The domain to set the cookie for.                  #
#                         Ex. '.host.com'                                    #
# Returns:       1 - If successful and value of $Cookie_Domain was set.      #
#                0 - If unsuccessful and value was not changed.              #
##############################################################################

sub SetCookieDomain {

    # Following Netscape specifications, if the domain specified is one of 7 #
    # top level domains, only require it to contain two periods, and if it   #
    # is not, require that there be three.  If the new domain passes error   #
    # checking, set the new domain and return a true value.  Otherwise,      #
    # return 0.  Trying to set a domain other than the current one is futile,#
    # since the browser won't allow it.  But if people may be accessing the  #
    # page from www.host.xxx or host.xxx, you may wish to set it to .host.xxx#
    # so that either host the access will have access to the cookie.         #

    if ($_[0] =~ /(.com|.edu|.net|.org|.gov|.mil|.int)$/i &&
        $_[0] =~ /\..+\.\w{3}$/) {
        $Cookie_Domain = $_[0];
        return 1;
    }
    elsif ($_[0] !~ /(.com|.edu|.net|.org|.gov|.mil|.int)$/i &&
           $_[0] =~ /\..+\..+\..+/) {
        $Cookie_Domain = $_[0];
        return 1;
    }
    else {
        return 0;
    }
}

##############################################################################
# Subroutine:    &SetSecureCookie()                                          #
# Description:   This subroutine will set the cookie to be either secure,    #
#                meaning the cookie will only be passed over a secure HTTP   #
#                channel, or unsecure, meaning it is safe to pass unsecured. #
# Usage:         &SetSecureCookie('flag')                                    #
# Variables:     flag - 0 or 1 depending whether you want it secure or not   #
#                       secure.  By default, it is set to unsecure, unless   #
#                       $Secure_Cookie was changed at the top.               #
#                       Ex. 1                                                #
# Returns:       1 - If successful and value of $Secure_Cookie was set.      #
#                0 - If unsuccessful and value was not changed.              #
##############################################################################

sub SetSecureCookie {

    # If the value passed to this script is a 1 or 0, set $Secure_Cookie     #
    # accordingly and return a true value.  Otherwise, return a false value. #

    if ($_[0] =~ /^[01]$/) {
        $Secure_Cookie = $_[0];
        return 1;
    }
    else {
        return 0;
    }
}

##############################################################################
# Subroutine:    &SetCookies()                                               #
# Description:   Sets one or more cookies by printing out the Set-Cookie     #
#                HTTP header to the browser, based on cookie information     #
#                passed to subroutine.                                       #
# Usage:         &SetCookies(name1,value1,...namen,valuen)                   #
# Variables:     name  - Name of the cookie to be set.                       #
#                        Ex. 'count'                                         #
#                value - Value of the cookie to be set.                      #
#                        Ex. '3'                                             #
#                n     - This is tacked on to the last of the name and value #
#                        pairs in the usage instructions just to show you    #
#                        you can have as many name/value pairs as you wish.  #
#               ** You can specify as many name/value pairs as you wish, and #
#                  &SetCookies will set them all.  Just string them out, one #
#                  after the other.  You must also have already printed out  #
#                  the Content-type header, with only one new line following #
#                  it so that the header has not been ended.  Then after the #
#                  &SetCookies call, you can print the final new line.       #
# Returns:       Nothing.                                                    #
##############################################################################

sub SetCookies {

    # Localize variables and read in cookies to be set.                      #

    local(@cookies) = @_;
    local($cookie,$value,$char);

    # While there is a cookie and a value to be set in @cookies, that hasn't #
    # yet been set, proceed with the loop.                                   #

    while( ($cookie,$value) = @cookies ) {

        # We must translate characters which are not allowed in cookies.     #

        foreach $char (@Cookie_Encode_Chars) {
            $cookie =~ s/$char/$Cookie_Encode_Chars{$char}/g;
            $value =~ s/$char/$Cookie_Encode_Chars{$char}/g;
        }

        # Begin the printing of the Set-Cookie header with the cookie name   #
        # and value, followed by semi-colon.                                 #

        print 'Set-Cookie: ' . $cookie . '=' . $value . ';';

        # If there is an Expiration Date set, add it to the header.          #

        if ($Cookie_Exp_Date) {
            print ' expires=' . $Cookie_Exp_Date . ';';
        }

        # If there is a path set, add it to the header.                      #

        if ($Cookie_Path) {
            print ' path=' . $Cookie_Path . ';';
        }

        # If a domain has been set, add it to the header.                    #

        if ($Cookie_Domain) {
            print ' domain=' . $Cookie_Domain . ';';
        }

        # If this cookie should be sent only over secure channels, add that  #
        # to the header.                                                     #

        if ($Secure_Cookie) {
            print ' secure';
        }

        # End this line of the header, setting the cookie.                   #

        print "\n";

        # Remove the first two values of the @cookies array since we just    #
        # used them.                                                         #

        shift(@cookies); shift(@cookies);
    }
}

##############################################################################
# Subroutine:    &SetCompressedCookies                                       #
# Description:   This routine does much the same thing that &SetCookies does #
#                except that it combines multiple cookies into one.          #
# Usage:         &SetCompressedCookies(cname,name1,value1,...,namen,valuen)  #
# Variables:     cname - Name of the compressed cookie to be set.            #
#                        Ex. 'CC'                                            #
#                name  - Name of the individual cookie to be set.            #
#                        Ex. 'count'                                         #
#                value - Value of the individual cookie to be set.           #
#                        Ex. '3'                                             #
#                n     - This is tacked on to the last of the name and value #
#                        pairs in the usage instructions just to show you    #
#                        you can have as many name/value pairs as you wish.  #
# Returns:       Nothing.                                                    #
##############################################################################

sub SetCompressedCookies {

    # Localize input into the compressed cookie name and the cookies to be   #
    # set.                                                                   #

    local($cookie_name,@cookies) = @_;
    local($cookie,$value,$cookie_value);

    # While there is a cookie and a value to be set in @cookies, that hasn't #
    # yet been set, proceed with the loop.                                   #

    while ( ($cookie,$value) = @cookies ) {

        # We must translate characters which are not allowed in cookies, or  #
        # which might interfere with the compression.                        #

        foreach $char (@Cookie_Encode_Chars) {
            $cookie =~ s/$char/$Cookie_Encode_Chars{$char}/g;
            $value =~ s/$char/$Cookie_Encode_Chars{$char}/g;
        }

        # Prepare the cookie value.  If a current cookie value exists, use   #
        # an ampersand (&) to separate the cookies and instead of using = to #
        # separate the name and the value, use double colons (::), so it     #
        # won't confuse the browser.                                         #

        if ($cookie_value) {
            $cookie_value .= '&' . $cookie . '::' . $value;
        }
        else {
            $cookie_value = $cookie . '::' . $value;
        }

        # Remove the first two values of the @cookies array since we just    #
        # used them.                                                         #

        shift(@cookies); shift(@cookies);
    }

    # Use the &SetCookies array to set the compressed cookie and value.      #

    &SetCookies("$cookie_name","$cookie_value");
}

##############################################################################
# Subroutine:    &GetCompressedCookies()                                     #
# Description:   This subroutine takes the compressed cookie names, and      #
#                optionally the names of specific cookies you want returned  #
#                and uncompressed them, setting the values into %Cookies.    #
#                Specific names of cookies are optional and if not specified #
#                all cookies found in the compressed cookie will be set.     #
# Usage:         &GetCompressedCookies(cname,[names])                        #
# Variables:     cname - Name of the compressed cookie to be uncompressed.   #
#                        Ex. 'CC'                                            #
#                names - Optional names of cookies to be returned from the   #
#                        compressed cookie if you don't want them all.  The  #
#                        [] depict a list of optional names, don't use [].   #
#                        Ex. 'count'                                         #
# Returns:       1 - If successful and at least one cookie is retrieved.     #
#                0 - If no cookies are retrieved.                            #
##############################################################################

sub GetCompressedCookies {

    # Localize variables used in this subroutine as well as the compressed   #
    # cookie name and the cookies to retrieve from the compressed cookie.    #

    local($cookie_name,@ReturnCookies) = @_;
    local($cookie_flag) = 0;
    local($ReturnCookie,$cookie,$value);

    # If we can get the compressed cookie, proceed.                          #

    if (&GetCookies($cookie_name)) {

        # If there are specific cookies which we should set, rather than all #
        # cookies found in the compressed cookie, then only retrieve them.   #

        if ($ReturnCookies[0] ne '') {

            # For each cookie that was found in the compressed cookie:       #

            foreach (split(/&/,$Cookies{$cookie_name})) {

                # Split the cookie name and value pair.                      #

                ($cookie,$value) = split(/::/);

                # Decode any URL encoding which was done when the compressed #
                # cookie was set.                                            #

                foreach $char (@Cookie_Decode_Chars) {
                    $cookie =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                    $value =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                }

                # For each cookie in the specified cookies we should set,    #
                # check to see if it matches the cookie we are looking at    #
                # right now.  If so, set that cookie in the %Cookies array   #
                # and set the cookie flag to 1.                              #

                foreach $ReturnCookie (@ReturnCookies) {
                    if ($ReturnCookie eq $cookie) {
                        $Cookies{$cookie} = $value;
                        $cookie_flag = 1;
                    }
                }
            }
        }

        # Otherwise, if there are no specific cookies to set, we will set    #
        # all cookies we find in the compressed cookie.                      #

        else {

            # Split the compressed cookie and split the cookie name/value    #
            # pairs, setting them in %Cookies.  Also set cookie flag to 1.   #

            foreach (split(/&/,$Cookies{$cookie_name})) {
                ($cookie,$value) = split(/::/);

                # Decode any URL encoding which was done when the compressed #
                # cookie was set.                                            #

                foreach $char (@Cookie_Decode_Chars) {
                    $cookie =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                    $value =~ s/$char/$Cookie_Decode_Chars{$char}/g;
                }

                $Cookies{$cookie} = $value;
            }
            $cookie_flag = 1;
        }

        # Delete the compressed cookie from the %Cookies array.              #

        delete($Cookies{$cookie_name});
    }

    # Return the cookie flag, which tells whether any cookies have been set. #

    return $cookie_flag;
}

# This statement must be left in so that when perl requires this script as a #
# library it will do so without errors.  This tells perl it has successfully #
# required the library.                                                      #

1;