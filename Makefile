OCAMLC_FLAGS = -package angstrom -package csv -package unix

all: build/sql

build/sql: src/ast.cmo src/parser.cmo src/lexer.cmo src/eval.cmo src/main.cmo
	cd src && \
	ocamlfind ocamlc $(OCAMLC_FLAGS) -linkpkg -o ../build/sql ast.cmo parser.cmo lexer.cmo eval.cmo main.cmo

build/sqlc: src/ast.cmo src/parser.cmo src/lexer.cmo src/eval.cmo src/main.cmo src/compile.cmo
	cd src && \
	ocamlfind ocamlc $(OCAMLC_FLAGS) -linkpkg -o ../build/sqlc ast.cmo parser.cmo lexer.cmo compile.cmo

src/ast.cmo: src/ast.ml
	cd src && ocamlfind ocamlc -c ast.ml

src/eval.cmo: src/eval.ml
	cd src && ocamlfind ocamlc $(OCAMLC_FLAGS) -c eval.ml

src/main.cmo: src/parser.cmo src/lexer.cmo src/ast.cmo src/eval.cmo src/main.ml
	cd src && ocamlfind ocamlc $(OCAMLC_FLAGS) -c main.ml

src/lexer.cmo: src/parser.cmo src/lexer.ml
	cd src && ocamlfind ocamlc $(OCAMLC_FLAGS) -c lexer.ml

src/parser.cmo: src/parser.mly
	cd src && ocamlyacc parser.mly && ocamlfind ocamlc $(OCAMLC_FLAGS) -c parser.mli && ocamlfind ocamlc $(OCAMLC_FLAGS) -c parser.ml

src/lexer.ml: src/lexer.mll
	cd src && ocamllex lexer.mll

src/compile.cmo: src/compile.ml
	cd src && ocamlfind ocamlc $(OCAMLC_FLAGS) -c compile.ml

clean:
	rm -f src/*.cmo src/*.cmi src/*.mli src/{parser,lexer}.ml
