# sqlc

> [!WARNING]
> THIS PROJECT IS EXPIRIMENTAL AND SHOULD NOT BE USED IN PRODUCTION

sqlc is a basic SQL statement parser and executor written in OCaml. It provides a simple and efficient way to parse and execute SQL statements.

It uses csv files as tables, and directories as databases.

## Features

- **SQL Parsing**: sqlc can parse a simple range of SQL statements, including SELECT, INSERT, UPDATE, DELETE, and more.
- **Query Execution**: sqlc provides a basic query execution engine that can execute SQL statements against a database.

### Supported Statements

sqlc currently supports the following SQL statements:

- `SELECT column1, column2, ... FROM IDENTIFIER [ WHERE condition ];`
- `CREATE DATABASE IDENTIFIER;`
- `USE DATABASE IDENTIFIER;`
- `CREATE TABLE IDENTIFIER ( table_columns );`
- `SHOW TABLES;`
- `SHOW DATABASES;`
- `INSERT INTO IDENTIFIER ( column1, column2, ... ) VALUES ( value1, value2, ... ) [ ( value1, value2, ... ) ... ];`
- `UPDATE IDENTIFIER SET IDENTIFIER EQUALS value [ WHERE condition ];`
- `DELETE FROM IDENTIFIER [ WHERE condition ];`
- `DROP TABLE IDENTIFIER;`
- `DROP DATABASE IDENTIFIER;`
- `EXIT;`

The condition is a simple expression that can include logical operators (`AND`, `OR`, `NOT`), comparison operators (`=`, `<>`, `>`, `<`, `>=`, `<=`), and parentheses.

## Getting Started

To get started with sqlc, follow these steps:

1. Install OCaml on your system.
2. Clone the sqlc repository.
3. Build the project using the provided build script.
4. Start using sqlc.

Or download from the release page.

For more detailed instructions, please refer to the [Installation Guide](./docs/installation.md) in the project documentation.

## Contributing

Contributions to sqlc are welcome! If you would like to contribute, please follow the guidelines outlined in the [Contributing Guide](./CONTRIBUTING.md).

## License

sqlc is licensed under the GNU General Public License v3.0. For more information, please refer to the [LICENSE](./LICENSE) file.
