from setuptools import setup, find_packages

setup (
  name = 'Balzac lexer and style',
  packages = find_packages(),
  entry_points = {
    "pygments.lexers" : [ "balzac = balzac:BalzacLexer" ],
    "pygments.styles" : [ "eclipse = eclipse:EclipseStyle"]
  }
)