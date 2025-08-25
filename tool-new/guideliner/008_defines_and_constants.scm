; matches incorrect define call
(
	(function_call_expression
		function: (name) @fnname
		arguments: (arguments (argument (_) @arg1) (argument (_)))
	)

	(#eq? @fnname "define")
	(#match? @arg1 "^[\"\'].*[a-z]")
)

; matches incorrect class constant
(
	(const_element (name) @name)
	(#match? @name "[a-z]")
)
