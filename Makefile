all:
	dune build

run:
	dune exec sql

clean:
	rm -rf _build
	rm -rf release

dist:
	dune install --prefix=release
	tar -zcvf sqlc.tar.gz release