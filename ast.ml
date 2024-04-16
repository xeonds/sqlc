program:
    | commands

commands:
    | command
    | command commands

command:
    | CREATE DATABASE ID
    | USE DATABASE ID
    | CREATE TABLE ID '(' columns ')'
    | SHOW TABLES
    | INSERT INTO ID '(' columns ')' VALUES '(' values ')'
    | SELECT columns FROM ID
    | UPDATE ID SET column '=' expr WHERE condition
    | DROP TABLE ID
    | DROP DATABASE ID
    | EXIT

columns:
    | column
    | column ',' columns

column:
    | ID TYPE
    | ID

values:
    | value
    | value ',' values

value:
    | INT
    | STRING

expr:
    | INT
    | ID

condition:
    | ID '=' INT
