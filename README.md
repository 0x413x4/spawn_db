# spawn_db
## Introduction
spawn_db is a small bash script which pulls docker images for various databases and spawn a local instance that is ready to use.

This comes particularly useful when investigating SQL injections, to quickly lab up and get back to focusing on exploitation.

At the moment, the following databases are supported:
- MySQL
- Microsoft SQL
- Postgres SQL
- Oracle Database

## Usage
```bash
alexa@deadbeef:~ []
22:22 > spawn_db -h  
====================
==    spawn_db    ==
====================

Usage: 
$ spawn_db.sh [mssql | mysql | oracle | postgres]
```

## Pre-requirements
- docker
- openssl (Used to generate random passwords)

For Windows users, an easy workflow can be to use the script on WSL2

## Example
[![asciicast](https://asciinema.org/a/mKaOf5W07I8A9bgeiccwggAtm.png)](https://asciinema.org/a/mKaOf5W07I8A9bgeiccwggAtm)

