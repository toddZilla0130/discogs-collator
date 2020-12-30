#! /usr/bin/ruby

require 'csv'

=begin
1.  validate command line args:
    if 2 args, source == arg[0]; target == arg[1]
    if 3rd arg, output == arg[2]
    if not 3rd arg, output== arg[2]-collated.csv (figure it out)
    source & target must exist, or print usage & bail.
    for now, blithely overwrite ouput if it exists. may prompt in a future iteration
2.  flow:
    open both files
    read source into a class that makes it easy to query "artist" and "collating artist" fields.
    for each line of target:

3.  classes:
=end