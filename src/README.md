# sqlc

## http_engine

provide stdlib for:

- request path & type mapper
- request handler with sql-ex lang
- json support

the http-lib should run at backend, when executed the part, just open a thread at backend to handle requests, until the main process(repl engine or executor process) exited. 

and it will show logs to stdout when handle request, and can be set to be silent.

also, support interactions with other stdlib components, like run sql from http content using sql_engine, 
storage content to filesystem, and string process using io_engine, data manipulation using data_engine, etc.

## sql_engine

provides stdlib for:

- sql engine for csv database operation

this part is standard sql database support, supporting acid actions and some dbms features

now I'm planning support higher query process like join, groupby, etc., and core features 
like transactions, views, permission control.

## io_engine

provides stdlib for:

- file i/o of system
- string process lib

support file i/o, string process, and auto-serialize of data types. user can serialize data to 

## data_engine

provides stdlib for:

- array operations
- basic data types
- user-defined compose data types

## main

entrance of program, supports interactive mode or headless mode(read command from file)

## ast

language statements & expressions & data types defination

## parser&lexer

language words & language statements parser
