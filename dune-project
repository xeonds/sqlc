(lang dune 3.16)

(name sqlc)

(source
 (github xeonds/sqlc))

(authors "xeonds")

(maintainers "Maintainer Name")

(license GPL-3.0)

(documentation https://github.com/xeonds/sqlc)

(package
 (name sqlc)
 (synopsis "A SQL compiler")
 (description "A SQL compiler")
 (depends ocaml dune csv angstrom)
 (tags
  (topics sql)))
