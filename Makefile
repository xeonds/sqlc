OCAMLC_FLAGS = -package angstrom -package csv

sqlc: src/parser.cmo src/lexer.cmo src/main.cmo
	cd src && \
		ocamlfind ocamlc $(OCAMLC_FLAGS) -o ../sqlc ast.ml lexer.ml main.ml && \
		rm parser.mli lexer.ml parser.ml

src/main.cmo: src/parser.ml src/main.ml
	cd src && ocamlc -c main.ml

src/lexer.cmo: src/lexer.ml
	cd src && ocamlc -c lexer.ml

src/parser.cmo: src/parser.ml
	cd src && ocamlc -c parser.ml

src/lexer.ml: src/lexer.mll
	cd src && ocamllex lexer.mll && ocamlc -c lexer.ml

src/parser.ml: src/parser.mly
	cd src && ocamlyacc parser.mly && ocamlc -c parser.mli

clean:
	rm -f src/*.cmo src/*.cmi src/*.mli src/{parser,lexer}.ml sqlc
