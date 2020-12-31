#! /usr/bin/ruby

require 'csv'

=begin
1.  validate command line args:
    if 2 args, source = arg[0]; target = arg[1]
    if 3rd arg, output = arg[2]
    if not 3rd arg, output = arg[2]-collated.csv (figure it out)
    if < 2 args, print usage and bail.
    source & target must exist, or print usage & bail.
    for now, blithely overwrite ouput if it exists. may prompt in a future iteration
2.  flow:
    open both files
    read source into a class that makes it easy to query "artist" and "collating artist" fields.
    for each line of target:

3.  classes:
=end

=begin
more crap:
    when reading in source file, take care of "the." Not sure how, but do it.
=end

# Strips beginning "A, An, The". Better would be to move to end, but for this use case it's not necessary
def fix_start(chk_artist)
    return chk_artist if chk_artist == "The The" # outlier
    return chk_artist[2..-1] if chk_artist.start_with?('A ')
    return chk_artist[3..-1] if chk_artist.start_with?('An ')
    return chk_artist[4..-1] if chk_artist.start_with?('The ')
    return chk_artist
end


SOURCE_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440-collated.csv'
TARGET_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440.csv'

the_artists = Hash.new

# need to read the first line (col headers) of the CSV as plain text for the output
the_source = CSV.parse(File.read(SOURCE_FILE), headers: true)
the_source.each do |the_entry|
    artist = the_entry['Artist']
    the_artists[the_entry['Artist']] = the_entry['CollatedArtist']
end


the_target = CSV.parse(File.read(TARGET_FILE), headers: true)
the_target.each do |the_entry|
    puts the_entry
    artist = the_entry['Artist']
    collated_artist = the_artists[artist]
    puts "#{artist} -> #{collated_artist}"
end