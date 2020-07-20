# HRS 
## Author: Amit Klein, Safebreach.

HTTP Request Smuggling demonstration Perl script, for variants 1, 2 and 5 in my BlackHat US 2020 paper [HTTP Request Smuggling in 2020](https://www.blackhat.com/us-20/briefings/schedule/#http-request-smuggling-in---new-variants-new-defenses-and-new-challenges-20019). 

Running:
smuggle.pl host port variant(1/2/5) POST_path target_path poison_path

Examples:
- Variant 1 (Header SP junk):
smuggle.pl www.example.com 80 1 /hello.php /welcome.html /poison.html
- Variant 2 (Header SP junk + Wait):
smuggle.pl www.example.com 80 2 /hello.php /welcome.html /poison.html
- Variant 5 (CR Header + Wait):
smuggle.pl www.example.com 80 5 /hello.php /welcome.html /poison.html
