<!--#include virtual="header.html" -->

<body>

<h1 class="title">Processing Weblog Files</h1>

<p>

<h2>Introduction</h2>

<p>
When you surf the World Wide Web, you use a <i>web browser</i>, such
as <a href="http://www.mozilla.com/firefox">Firefox</a>, to get web
pages from a <i>web server</i>, such as <a
href="http://httpd.apache.org/">apache</a>.  For example, if you click
the first link above, which has the URL
<tt>http://www.mozilla.com/firefox</tt>, then your web browser will
connect to the web server running on the machine
<tt>www.mozilla.org</tt> and ask it for the web page <tt>firefox</tt>.

<p>
There's a lot more we could say about web browsers and web servers, but
for this project, there's only one other thing you need to know: Most
web servers are configured to <i>log</i> all the requests they get to
a file.  For example, the following is a line from the CS department
web log that resulted from a request for the CMSC 330 main web page:
<pre>
209.17.153.170 - - [03/Aug/2007:11:34:36 -0400] "GET /class/fall2007/cmsc330/ HTTP/1.1" 200 2488
</pre>
From left-to-right, this log entry means: The request came from IP
address 209.17.153.170; the date was August 3, 2007 at the time shown;
the request was for the page <tt>/class/fall2007/cmsc330/</tt>, and
the web browser understands http version 1.1; the request was
successful (status code 200); and 2488 bytes were sent from the web
server to the web browser.

<p>
As you can imagine, there are many reasons for the CS department, and
anyone else who runs a web server, to maintain web logs.  For example,
we might want to know which web pages are the most popular on our web
site, or what time of day our web server gets the most hits.  In this
project, you will write a Ruby program that parses web logs of the
form shown above and reports various summary information.

<h2>Part 1:  Validating log files</h2>

<p>
The first part of this project is to write a Ruby script that
validates that an input file is in fact a web log and not, e.g., Aunt
Bertha's secret apple pie recipe.  We will select this task by passing
the mode <tt>validate</tt> to your Ruby script.  In particular, to
test your solution to part 1, we will invoke your program with
<center> <tt>ruby weblog.rb validate</tt>
<i>log-file-name</i> </center>

<p>
In response, your script should output exactly one line of text and
then exit.  That line should either contain the three letters
<tt>yes</tt> followed by a newline if the log file is valid, or the
two letters <tt>no</tt> followed by a newline otherwise.

<p>
A valid log file contains zero or more lines of text, each of which
ends in a newline.  (Hint: There are Ruby methods to read in a single
line of text at a time.)  Each line must contain the following fields
from left-to-right, with each field separated from the previous field
with a single space.  The left-most field has nothing in front of it,
and the right-most field is followed only by the newline that ends the
line:

<ul>

<li>The first field is a numeric IP address.  The address contains
four numbers in the range 0-255 separated by a period.  (Note that by
<i>separated</i> we mean that there are three periods total; if the
period were a <i>terminator</i>, then there would be four periods.)

<li>Next is a hyphen <tt>-</tt> (this could in theory be a
different symbol, but it never happens). For the purposes of this
project, you only need to verify that the hyphen is present.

<li>Next is the name of the user requesting the page, which may
contain any alphabetic characters (upper or lowercase), numbers, and
underscore.  The user name may be <tt>-</tt> if no user has been
determined.

<li>Next is the date the web page was requested.  Here is the format
for the date as described in the apache documentation:
<pre>
    [day/month/year:hour:minute:second zone]
    day = 2*digit
    month = 3*letter
    year = 4*digit
    hour = 2*digit
    minute = 2*digit
    second = 2*digit
    zone = (`+' | `-') 4*digit
</pre>

For this project, we will require a slightly stricter set of strings:
The day must be in the range <tt>01</tt>-<tt>31</tt> (regardless of
the month); the month must be in the range <tt>Jan</tt>-<tt>Dec</tt>;
the hour must be in the range <tt>00</tt>-<tt>23</tt>, and minutes and
seconds must be in the range <tt>00</tt>-<tt>59</tt>; and the zone
(which indicates the time zone) will always be <tt>-0400</tt>.

<li>Next is the request itself, which is an arbitrary string that
begins and ends with double quotes.  Inside of the string any occurrence
of double quote must be escaped by being prefixed with backslash.

<li>Next is the status code, a non-negative integer

<li>Last is the number of bytes sent, either a non-negative integer or
<tt>-</tt> if nothing was sent to the requester.
</ul>

<p>
Any file whose lines do not conform to these rules is invalid. Extra
whitespace between any fields (or at the beginning or end of the line) 
is not valid.

<p>
<i>Hint:</i> It might be easier to write a regular expression that
accepts a line in a more general format, and then check after it's
been split into pieces that the various range constraints have been
satisfied.

<h2>Part 2:  Gathering statistics</h2>

<p>
The next part of the project is to add additional modes to your Ruby script
that summarize various aspects of the web log.  You will write three
new modes, as described below.  You may assume that we will only use
these new modes on log files that are valid.

<h3>Mode:  bytes</h3>

<p>
In this mode, you should output the total number of bytes sent by the
web server across all log entries.  This size should be reported in the
largest appropriate unit (bytes, KB, MB, GB) and 
<a href="http://en.wikipedia.org/wiki/Truncation">truncated</a> to an 
integer (e.g., 7.9 -> 7).  
Remember that 1024 bytes = 1 KB, and 1024 KB = 1 MB, etc.  So
if if the total size is 1337 bytes, your program should output "1 KB".
If the total size is 42000000 bytes, your program should output "40 MB".
Any size larger than 1 GB should be reported in GB. There should be a
single space between the number and the unit.

<p>
The output should be a single line of text containing this number with
units as described above, terminated by a newline.  For example,
a sample run of your script might look like:
<pre>
% ruby weblog.rb bytes sample.log
238 KB
</pre>
<i>Hint:</i>  Remember that the web server uses <tt>-</tt> to indicate
no bytes sent by the web server.

<p> In bytes mode, the smallest unit is "bytes".  
Sizes less than 1024 (1 KB) should be reported as # of bytes 
(e.g., "12 bytes").  For 0, the correct output 
(both grammatically and for project grading) is "0 bytes", not
"0 byte".  For 1, the correct output (for project grading)
is "1 bytes", not "1 byte" (despite it being grammatically incorrect).  

<p>
<h3>Mode:  time</h3>

<p>
In this mode, you should produce a histogram indicating the total
number of requests that were served in each possible hour of the day,
totaled across all requests on all days.  You should ignore the time
zone part of the log entry (recall that they're always <tt>-0400</tt>
for this project).  Your output should consist of 24 lines listing the
two-digit hour, followed by space, followed by the number of requests
(which may be zero), followed by a newline.  For example, a sample run
of your script might look like:
<pre>
% ruby weblog.rb time sample.log
00 8
01 3
02 0
...
23 5
</pre>
meaning that 8 requests were served between 00:00:00 and 00:59:59 in
time zone -0400, inclusive, 3 requests were served between 01:00:00
and 01:59:59, inclusive, and so on.

<h3>Mode:  popularity</h3>

<p>
In this mode, you should produce a list containing the top-ten most
common <i>request strings</i> (not web pages) received by the web
server, across all entries in the log file.  The output should contain
at most ten lines (<i>Hint</i>:  You need to handle the case where
there are fewer than ten different requests), one line per popular request.
Each line should contain the total number of times the request was
received, followed by a space, followed by the request string, which
should still include quotes.  The lines should be sorted from most
popular to least popular.  For example, a sample run of your script
might look like:
<pre>
% ruby weblog.rb popularity sample.log
5 "GET /hcil/_includes/publications-2-col.html HTTP/1.0"
3 "GET /class/fall2005/cmsc412/ HTTP/1.1"
2 "GET /class/fall2005/cmsc417/ HTTP/1.1"
...
</pre>

</ul>

<h3>Mode:  requests</h3>
<p>
In this mode, you should calculate for each IP address
the total number of requests received by the web server
and the number of bytes transferred to that IP address,
across all entries in the log file.  
Each line of output should contain an IP address, 
the number of requests received from that IP address, 
and the total number of bytes sent to that IP address,
separated by spaces.  The lines should be sorted by the
IP address.  For IPv4 IP addresses listed as 4 numbers,
sort starting with the first number and break ties using later 
numbers.  For example, a sample run of your script
might look like:
<pre>
% ruby weblog.rb requests sample.log
128.0.1.3 1 300
128.0.1.21 3 250
128.0.2.1 2 350
...
</pre>

<h2>Notes</h2>

<li> You may assume single digit numbers in IP 
addresses (e.g., 192.168.1.5) will not have leading zeros.  
Numbers in in the weblog date entry <i>will</i> 
have leading zeros if they have less than the maximum number
of digits for that field (e.g., 25/Jul/2006:01:02:02).

<p>
<li> Requests in weblog entries <i>may</i>
contain quotation marks, if they are escaped with a backslash.
In other words, "GET /class/"notes".txt" is an illegal request,
but "GET /class/\"notes\".txt" is legal.

<p>
<li> For bytes mode, truncated means drop 
fractional values when converting to an integer. So 9.9999999 => 9

<p>
<li> You may assume that all test files will end 
in literal newline characters '\n' only.

<p>
<li> You may assume that the logfile exists,
its name is passed correctly on the command line,
and is valid when in bytes, time, and popularity mode.

<p>
<li> You may assume that if there are 2 requests 
that appear the same number of times, the order you output them 
in the "popularity" mode is not significant. Or just assume that 
in project 1 testing, there will be no ties among the top 10 most 
popular requests for tests of "popularity" mode.

</ul>

</td>
</table>

</body>
</html>
