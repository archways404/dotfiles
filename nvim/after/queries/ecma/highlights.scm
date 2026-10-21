; extends

; Keep local declarations purple, and exported declarations pink.
((lexical_declaration ["const" "let"] @keyword.declaration)
 (#set! priority 140))
((variable_declaration "var" @keyword.declaration)
 (#set! priority 140))
((export_statement
   declaration: (lexical_declaration ["const" "let"] @keyword.declaration.export))
 (#set! priority 150))
((export_statement
   declaration: (variable_declaration "var" @keyword.declaration.export))
 (#set! priority 150))
