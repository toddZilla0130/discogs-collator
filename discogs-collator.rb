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
        @target_fn = target_file
        read_target #rename - now also writes output
    end

    private # ----------------------------

    def csv_header target_entry
        collated_artist_index = target_entry.index(ARTIST)+1
        headers = target_entry.headers.insert(collated_artist_index, COLLATED_ARTIST)
        CSV::Row.new(headers, headers).to_csv # this seems a little weird but if I tried to return `headers` the output was borked
    end

    def output_fn
        File.dirname(@target_fn)+'/'+File.basename(@target_fn, File.extname(@target_fn))+'-collated'+File.extname(@target_fn)
    end

    def read_target
        target_csv = CSV.parse(File.read(@target_fn), headers: true)
        header_read = false
        File.open(output_fn, 'w') do |csv_file|
            target_csv.each do |target_thingy|
                if !header_read
                   csv_file << csv_header(target_thingy)
                   header_read = true
                end
                output_line = Target_entry.new(target_thingy, @@artist_hash).add_collated # this will be a CSV TEXT line, not a CSV::Row object.
                csv_file << output_line
            end
        end
    end

end # class Target

  ########
 # MAIN #
########
if ARGV.count < 2
    $stderr.puts "Usage: ruby discogs-collator.rb source.csv target.csv"
    $stderr.puts "Where: source.csv is the previous iteration with collated artists"
    $stderr.puts "       target.csv is the newly-exported file from discogs.com"
    $stderr.puts "Both source.csv and target.csv must be findable. Minimal error checking is done currently."
    $stderr.puts "Output will be written to target-collated.csv in the same dir as target.csv"
    $stderr.puts "Fill in new collated artists and save as .csv. This becomes source.csv for the next iteration."
    return 1
end

source_file = ARGV[0]
target_file = ARGV[1]

my_target = Target.new(target_file, source_file)
