;
; capture comment nodes that begin with "/**"
; first "\" escapes scm syntax, second "\" - regex syntax for a literal "*"
;
((comment) @cap (#match? @cap "^\/\\*\\*"))
