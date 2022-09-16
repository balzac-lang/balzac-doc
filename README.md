# Balzac Documentation
[![Python application](https://github.com/balzac-lang/balzac-doc/actions/workflows/python-app.yml/badge.svg)](https://github.com/balzac-lang/balzac-doc/actions/workflows/python-app.yml)

## Requirements

The documentation is generated with [Sphinx](http://sphinx-doc.org). Use `pip` to install the dependencies:

```
pip install sphinx pygments sphinxcontrib-inlinesyntaxhighlight
```

## Available commands

Run `make` to list the available commands:
```shell
Please use `make <target>' where <target> is one of
  build                to build the documentation
  clean                to clean the documentation
  build-fatal-warnings to build the documentation and fail if there are warnings
  install-lexer        to install the lexer and the style
  remove-lexer         to remove the lexer and the style
  full-build           to install the lexer and build the documentation
  full-clean           to remove the lexer and clean the documentation
  loop                 to rebuild the documentation on changes
  server               to start an http server using Python 3
  server2              to start an http server using Python 2

 Other commands
  html       to make standalone HTML files
  dirhtml    to make HTML files named index.html in directories
  singlehtml to make a single large HTML file
  pickle     to make pickle files
  json       to make JSON files
  htmlhelp   to make HTML files and a HTML help project
  qthelp     to make HTML files and a qthelp project
  applehelp  to make an Apple Help Book
  devhelp    to make HTML files and a Devhelp project
  epub       to make an epub
  latex      to make LaTeX files, you can set PAPER=a4 or PAPER=letter
  latexpdf   to make LaTeX files and run them through pdflatex
  latexpdfja to make LaTeX files and run them through platex/dvipdfmx
  text       to make text files
  man        to make manual pages
  texinfo    to make Texinfo files
  info       to make Texinfo files and run them through makeinfo
  gettext    to make PO message catalogs
  changes    to make an overview of all changed/added/deprecated items
  xml        to make Docutils-native XML files
  pseudoxml  to make pseudoxml-XML files for display purposes
  linkcheck  to check all external links for integrity
  doctest    to run all doctests embedded in the documentation (if enabled)
  coverage   to run coverage check of the documentation (if enabled)

```

## Docker build

Build the image assuming the documentation is stored in `build/html`.

```
docker build -t balzaclang/balzac-doc:latest .
```

Run the image on port 8080

```
docker run --rm --name balzac-doc -p 8080:80 balzaclang/balzac-doc:latest
```

The documentation is visible at http://localhost:8080

### Prebuilt image

DockerHub: [balzaclang/balzac-doc](https://hub.docker.com/r/balzaclang/balzac-doc)

```
docker pull balzaclang/balzac-doc:latest
```

Balzac documentation is available for the following architectures:

```
- linux/amd64
- linux/arm/v7
- linux/arm64
```
