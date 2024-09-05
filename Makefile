all:
	dune build

run:
	dune exec sql

clean:
	rm -rf _build
