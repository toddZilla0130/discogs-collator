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
    def initialize(source_file)
        @artists = Hash.new
        @source = source_file
        extract_artists
    end

    def collated_artist(artist)
        @artists[artist] # will return the collated artist or null
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
        # ditto above but inserting the value
        fields = @target_entry.fields.insert(collated_artist_index, collated_artist)
        CSV::Row.new(headers, fields).to_csv # return this thing
    end
end # class Target_line


#############################################################
# consider renaming this class... it's pretty much the App at this point...
class Target
    def initialize(target_file, source_file)
        @@artist_hash = Source.new source_file
        @target = CSV.parse(File.read(target_file), headers: true)
        output_csv = Array.new
        the_stuff = read_target
        output_csv << the_stuff
        Output.new(target_file, output_csv)
        #$stderr.puts output_csv
    end

    private # ----------------------------

    def csv_header target_entry
        collated_artist_index = target_entry.index(ARTIST)+1
        headers = target_entry.headers.insert(collated_artist_index, COLLATED_ARTIST)
        CSV::Row.new(headers, headers).to_csv # this seems a little weird but if I tried to return `headers` the output was borked
    end

    def read_target
        buffer = Array.new
        header_read = false
        @target.each do |target_thingy|
            output_line = Target_entry.new(target_thingy, @@artist_hash).add_collated # this will be a CSV TEXT line, not a CSV::Row object.
            if !header_read
                buffer << csv_header(target_thingy)
                header_read = true
            end
            buffer << output_line
        end
        buffer
    end

end # class Target

class Output
    def initialize(target_file, csv_buff)
        @fname = target_file
        @csv_buff = csv_buff
        write_it_already_sheesh
    end

    private #--------------------------------
    def output_fn
        File.dirname(@fname)+'/'+File.basename(@fname, File.extname(@fname))+'-collated'+File.extname(@fname)
    end

    def write_it_already_sheesh
        CSV.open(output_fn, 'wb') do |csv_file|
            puts @csv_buff.class
            @csv_buff.each do |csv_line| 
                puts csv_line.class
                puts csv_line
                csv_file << csv_line
            end
        end
    end

end # class Output

# SOURCE_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440-collated.csv'
# TARGET_FILE = '/Users/toddsteinwart/repos/discogs-collator/ToddZilla0130-collection-20201230-0440.csv'

if ARGV.count < 2
    $stderr.puts "Usage: ruby discogs-collator.rb source.csv target.csv"
    $stderr.puts "Where: source.csv is the previous iteration with collated artists"
    $stderr.puts "       target.csv is the newly-exported file from discogs.com"
    $stderr.puts "Both source.csv and target.csv must be fully qualified if not in cwd. Minimal error checking is done currently."
    $stderr.puts "Output will be written to target-collated.csv in the same dir as target.csv"
    $stderr.puts "Fill in new collated artists and save as .CSV. This becomes source.csv for the next iteration."
    return 1
end

source_file = ARGV[0]
target_file = ARGV[1]

my_target = Target.new(target_file, source_file)


