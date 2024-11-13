(function_call_expression
  function: (name) @name
  arguments: (arguments) (#any-of? @name
    "_" ; Stub gettext function in case gettext is not available.
    "_n" ; Supports unlimited parameters; placeholders must be defined as %1$s, %2$s etc.
    "_s" ; Translates the string and substitutes the placeholders with the given parameters.
    "_x" ; Translates the string with respect to the given context.
    "_xs" ; Translates the string with respect to the given context and replaces placeholders with supplied arguments.
    "_xn" ; Translates the string with respect to the given context and plural forms, also replaces placeholders with supplied arguments. If no translation is found, the original string will be used. Unlimited number of parameters supplied.
  ))
