# Requirements

The documentation is generated in Python (version 3, but it may work with Python 2 too).


Use `pip` to install the following Python packages:

```
pip install sphinx pygments sphinxcontrib-inlinesyntaxhighlight
```

# Available commands

```
make build-doc              # build the documentation
make build-doc-warning      # build the documentation and fail if there are warnings
make clean-doc              # clean the documentation
make install-lexer          # install the lexer for pygments
make remove-lexer           # remove the lexer from pygments
make full-clean             # clean the documentation and remove the lexers
make full-build             # build the documentation and install the lexers
make server                 # start a local server at port 8000 to view the docs
make loop                   # compile the docs every time a file changes
```

# Testing

In order to locally browse the documentations, start an HTTP server into the `build/html/` directory:
 
```
cd build/html/ && python2 -m SimpleHTTPServer 8000
```
or, if you are using Python 3,
```
cd build/html/ && python3 -m http.server 8000
```

This is the easiest way to serve local files. 
However, any HTTP server is fine.

Explore the documentations in your browser: <http://localhost:8000>
