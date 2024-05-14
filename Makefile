OCAMLC_FLAGS = -package angstrom -package csv

main: src/ast.ml src/main.ml
	cd src && ocamlfind ocamlc $(OCAMLC_FLAGS) -o ../sqlc ast.ml lexer.ml main.ml 

lexer: src/lexer.mll
	cd src && ocamllex lexer.mll

parser: src/parser.mly
	cd src && ocamlyacc parser.mly