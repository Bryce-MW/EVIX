# Experimental Virtual Internet Exchange Scripts

This repository contains the scripts used by [EVIX](https://evix.org). A majority of the scripts and configuration used
by EVIX are in this repository. While some parts of our scripts are easily configurable, there are still many areas
where there are hardcoded values. The main example is that almost everything uses `/evix` as the base directory. I would
like to allow relative directories someday but that's not an option quite yet. I am currently moving most config to the
`secret-config.json` file but there are places where that does not exist yet or is not possible. Essentially, what I am
saying is that you can't just download this onto a server and quickly set up a clone of EVIX. This repo doesn't even
have the database DDL available yet. I have mainly made this public for future employers and similar people. Perhaps
someday this will be a drop-in solution but that is not our goal. I will try to add in some documentation here in the
future, if only for the sake of our own volunteers.

Note: You will see quite a few commits from Chris. Few of them are actually from him. He is just the one logged in on
our main server so any commits done from the main server will look like they were from him even if they were from
someone else.