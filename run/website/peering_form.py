#! /usr/bin/env python3
import cgi
import cgitb
cgitb.enable()

print("Hello, World!")

cgi.print_environ_usage()
