(
  variable_name (name) @name
  (#match? @name "[A-Z]")
  (#not-eq? @name "_REQUEST")
  (#not-eq? @name "_SERVER")
)
