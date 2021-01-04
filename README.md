# discogs-collator
Adds a column to the discogs CSV output with old-school (aka "correct") artist collation.

### usage: 
`ruby discogs-collator.rb source-file.csv target-file.csv`

or (depending on your jam):

`./discogs-collator.rb source-file.csv target-file.csv`

where:

- `source-file.csv` is the _previous_ discogs export, run through this script and new artists updated.
- `target-file.csv` is the newly-exported discogs file.

`source-file.csv` and `target-file.csv` *must be fully qualified*.

Output will be written to `target-file-collated.csv` where "-collated" is a literal insertion. 

Once output is written open it, add new collations as necessary then save **as .csv**. This file becomes `source-file.csv` for the next iteration.

### notes:
- It is up to the user to provide correct files for source & target. (Duh.)