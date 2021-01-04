#! /usr/bin/ruby

require 'csv'

# (figure out if/how/whether this is worth doing)
# Strips beginning "A, An, The". Better would be to move to end, but for this use case it's not necessary
def fix_start(chk_artist)
    return chk_artist if chk_artist == "The The" # outlier
    return chk_artist[2..-1] if chk_artist.start_with?('A ')
    return chk_artist[3..-1] if chk_artist.start_with?('An ')
    return chk_artist[4..-1] if chk_artist.start_with?('The ')
    return chk_artist
end

COLLATED_ARTIST = 'CollatedArtist'
ARTIST = 'Artist'

#############################################################
class Source
    attr_reader :header  ## NO!
    def initialize(source_file)
        @artists = Hash.new
        @source = source_file
#        @header = File.open(source_file, &:gets) # found this one-liner trick on SO - returns the first line. closes file
        extract_artists
    end

    def collated_artist(artist)
        @artists[artist] # will return the collated artist or nul
    end

    private # --------------------
    
    def extract_artists
        csv_source = CSV.parse(File.read(@source), headers: true)
        csv_source.each do |csv_line|
            artist = csv_line[ARTIST]
            @artists[artist] = csv_line[COLLATED_ARTIST]
        end
    end

end # class Source

#############################################################
# this class also desperately wants renaming.
class Target_entry
    def initialize(target_entry, artist_hash)
        @target_entry = target_entry
        @artist_hash = artist_hash
    end

    def add_collated
        collated_artist = @artist_hash.collated_artist(@target_entry[ARTIST])
        collated_artist_index = @target_entry.index(ARTIST)+1 # not really necessary to keep doing this over and over, but...
        # add CollatedArtist header after array value with the 'Artist' value
        headers = @target_entry.headers.insert(collated_artist_index, COLLATED_ARTIST)
        $stderr.puts headers
        # ditto above but inserting the value
        fields = @target_entry.fields.insert(collated_artist_index, collated_artist)
        CSV::Row.new(headers, fields).to_csv # return this thing
    end
end # class Target_line

# CREATE NEW HEADER LINE FROM **TARGET** FILE. THAT WAY I CAN TRIM DOWN THE "SOURCE" FILE.

#############################################################
# consider renaming this class... it's pretty much the App at this point...
class Target
    def initialize(target_file, source_file)
        @@artist_hash = Source.new source_file
        @target = CSV.parse(File.read(target_file), headers: true)
        output_csv = Array.new
        # output_csv << @@artist_hash.header ## oops
        the_stuff = read_target
        output_csv << the_stuff
        #puts output_csv
    end

    private # ----------------------------

    def read_target
        buffer = Array.new
        @target.each do |target_thingy|
            output_line = Target_entry.new(target_thingy, @@artist_hash).add_collated # this will be a CSV TEXT line, not a CSV::Row object.
            buffer << output_line
        end
        buffer
    end

end # class

SOURCE_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440-collated.csv'
TARGET_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440.csv'
OUTPUT_FILE = '/Users/toddsteinwart/repos/discogs-collator/Glob.csv'

# something something command line args: 
# ...

my_target = Target.new(TARGET_FILE, SOURCE_FILE)
