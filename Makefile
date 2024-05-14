OCAMLC_FLAGS = -package angstrom -package csv

sqlc: src/ast.cmo src/eval.cmo src/parser.cmo src/lexer.cmo src/main.cmo
	cd src && \
	ocamlfind ocamlc $(OCAMLC_FLAGS) -o ../sqlc ast.cmo eval.cmo parser.cmo lexer.cmo main.cmo

src/ast.cmo: src/ast.ml
	cd src && ocamlfind ocamlc -c ast.ml

src/eval.cmo: src/eval.ml
	cd src && ocamlfind ocamlc -c eval.ml

src/main.cmo: src/parser.cmo src/lexer.cmo src/ast.cmo src/eval.cmo src/main.ml
	cd src && ocamlfind ocamlc -c main.ml

src/lexer.cmo: src/parser.cmo src/lexer.ml
	cd src && ocamlfind ocamlc -c lexer.ml

src/parser.cmo: src/parser.mly
	cd src && ocamlyacc parser.mly && ocamlfind ocamlc -c parser.mli && ocamlfind ocamlc -c parser.ml

src/lexer.ml: src/lexer.mll
	cd src && ocamllex lexer.mll

clean:
	rm -f src/*.cmo src/*.cmi src/*.mli src/{parser,lexer}.ml sqlc
