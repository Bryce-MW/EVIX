# NOTE(bryce): Written by Bryce Wilson on 2020-11-28. Just moved some strings out to a separate file.

multi_as_set_header = """as-set:          {name}\ndescr:           Combo AS-SET
remarks:         This object has been created automatically
remarks:         by a python script. Email
remarks:         bryce@thenetworknerds.ca if there are any
remarks:         issues.
remarks:         This object was created beacause someone
remarks:         has listed two AS-SETs so we had to make a
remarks:         combo object to work with programms that
remarks:         only support a single AS-SET"""

multi_as_set_footer = """\nmnt-by:          MAINT-AS396503
mnt-by:          MAINT-BRYCE
changed:         bmwilson@evix-svr1.evix.org {date}
source:          ALTDB"""

evix_as_set_header = """as-set:          AS-EVIX
descr:           Members of EVIX
remarks:         This object has been created automatically
remarks:         using a python script which reads from our members database.
remarks:         If there are errors, please email bryce@thenetworknerds.ca\n"""

evix_as_set_footer = """mnt-by:          MAINT-EVIX
changed:         root@evix-svr1.evix.org {date}
source:          ALTDB"""
