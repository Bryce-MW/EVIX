#! /usr/bin/env python3
import cgi
import cgitb
cgitb.enable()
print("Content-Type: text/html\n")  # DO NOT REMOVE

print("Hello, World!")

cgi.print_environ_usage()
