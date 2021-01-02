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

#############################################################
class Source
    attr_reader :header
    def initialize(source_file)
        @artists = Hash.new
        @source = source_file
        @header = File.open(source_file, &:gets) # found this one-liner trick on SO - returns the first line. closes file
        extract_artists
    end

    def collated_artist(artist)
        @artists[artist] # will return the collated artist or nul
    end

    private # --------------------
    
    def extract_artists
        csv_source = CSV.parse(File.read(@source), headers: true)
        csv_source.each do |csv_line|
            artist = csv_line['Artist']
            @artists[artist] = csv_line['CollatedArtist']
        end
    end

end # class Source

#############################################################
class Target_entry
    def initialize(target_entry, artist_hash)
        @target_entry = target_entry
        @artist_hash = artist_hash
    end

    def add_collated
        collated_artist = @artist_hash.collated_artist(@target_entry['Artist'])
        # Need to splice collated_artist into @target_entry, which is a CSV::Row. 
        # Is it possible to add something to the middle of it? Seems to be a prety rich class
        # so try finding the right method(s) before stringizing and splicing in that way.
    end
end # class Target_line

#############################################################
class Target
    def initialize(target_file, artist_hash)
        @target = CSV.parse(File.read(target_file), headers: true)
        @artist_hash = artist_hash
        read_target ## and do what exactly?
    end

    private # ----------------------------

    def read_target
        @target.each do |target_thingy|
            output_line = Target_entry.new(target_thingy, @artist_hash).add_collated # this will be a TEXT line, not a CSV array thing!
        end
    end




end # class

SOURCE_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440-collated.csv'
TARGET_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440.csv'
OUTPUT_FILE = '/Users/toddsteinwart/repos/discogs-collator/Glob.csv'




=begin
    open target file for *reading* ## AS CSV OR PLAIN TEXT?
    open output file for *writing*
    write headers to output file
    for each line in target
        collated_artist =  the_artists[target_line['Artist']] # will return NULL if no match
        output_line = splice collated_artist+',' after artist in target line
        append output_line to output_file
    end
=end

artist_hash = Source.new SOURCE_FILE
my_target = Target.new(TARGET_FILE, artist_hash)

# the_target = CSV.parse(File.read(TARGET_FILE), headers: true)
# the_target.each do |the_entry|
#     artist = the_entry['Artist']
#     collated_artist = artist_hash.collated_artist artist
#     # build output line:
    
# #    puts "#{artist} -> #{collated_artist}"
# end
