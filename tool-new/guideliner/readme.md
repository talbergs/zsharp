A single style rule check is implemented in pairs of files, like so:

    001_array_definition.md
    001_array_definition.scm

Where the `md` file describes the guideline and `scm` contains a query.
Rule has failed when query has matches.

Similarly, more complex style rule check is implemented in triples of files, like so:

    002_block_comment.md
    002_block_comment.scm
    002_block_comment.php

Query named capture groups are processed by php script that
would produce output, if rule has failed.
