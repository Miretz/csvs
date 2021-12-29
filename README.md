# csvs

Command Line tool written in OCaml for displaying and searching in CSV files.

<img src="screenshot.png" />

## Build:

### How to setup dev environment:
https://dev.realworldocaml.org/install.html

### Install required dependencies:
```bash
opam install base utop stdio pcre
eval $(opam env)
```

### Build executable using Dune:
```bash
dune build csvs.exe
```

## Run:

### Example search in the included test.csv:
```bash
./_build/default/csvs.exe test.csv , Jav
```

Output:
```bash
Entries found: 2

| Language   | Fun | Difficulty |
|____________+_____+____________|
| Java       | 5   | 4          |
| JavaScript | 6   | 4          |
```
