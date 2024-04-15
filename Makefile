OCAMLC_FLAGS = -I +angstrom

main: ast.ml eval.ml main.ml
	ocamlc $(OCAMLC_FLAGS) -o main ast.ml eval.ml main.ml