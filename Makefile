OCAMLC_FLAGS = -package angstrom -package csv

main: ast.ml eval.ml main.ml
	ocamlfind ocamlc $(OCAMLC_FLAGS) -o main ast.ml eval.ml main.ml

lexer: lexer.mll
	ocamllex lexer.mll

parser: parser.mly
	ocamlyacc parser.mly