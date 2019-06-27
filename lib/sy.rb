# coding: iso-8859-1
require "sy/version"
require "sy/parser"

require 'sy/type'
require 'sy/function'
require 'sy/sum'
require 'sy/subtraction'
require 'sy/minus'
require 'sy/product'
require 'sy/wedge'
require 'sy/fraction'
require 'sy/power'
require 'sy/variable'
require 'sy/constantsymbol'
require 'sy/number'
require 'sy/value'
require 'sy/matrix'
require 'sy/equation'
require 'sy/diff'
require 'sy/operation'
require 'sy/path'

# Create a collection of parameters for common settings and working environment
# Setting:
#   symbol for differentiation (d, ð, etc.)
#   symbol for vector (', ', ~, etc.)
#   normalization policy (how much normalzation?)
#   auto evaluate operators
#   display square root as x^(1/2) or sqrt(x)
# Working environment:
#   vector room
#   basis vectors (variable names)
#   basis co-vectors (or deduce from basis vectors)
#   assigned variables. List of v1 = bla, v2 = bla2, etc.
#   defined functions
#   defined operators
