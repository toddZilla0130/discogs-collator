# discogs-collator
Adds a column to the discogs CSV output with old-school (aka "correct") artist collation.

### usage: 
ruby discogs-collator.rb source-file.csv target-file.csv [output-file]

or (depending on your jam)

./discogs-collator.rb source-file.csv target-file.csv [output-file]

where:

- `source-file.csv` is the _previous_ discogs export, run through this script and new artists updated.
- `target-file.csv` is the newly-exported discogs file.
- `output-file` is optional. If specified, the updated target file will be written here. If unspecified, updated target file will be written to `target-file-collated.csv`.

`source-file.csv` and `target-file.csv` *must be fully qualified*. If `output-file` is fully qualified file will be written to that path; if not, `output-file` will be written to same directory as `target-file.csv`.

