# Sy expression parser

class Parser
  prechigh
    nonassoc UMINUS
    left '**'
    left '*' '/' '^'
    left '+' '-'
    left '='
    unassoc '.'
    CMD
  preclow
rule
  target: exp
     | /* none */      { result = nil }
  exp: CMD exp         { result = val[1].send(val[0]) }
     | exp '=' exp     { result = eq(val[0], val[2]) }
     | exp '+' exp     { result = val[0].add(val[2]) }
     | exp '-' exp     { result = val[0].sub(val[2]) }
     | exp '*' exp     { result = val[0].mul(val[2]) }
     | exp '/' exp     { result = val[0].div(val[2]) }
     | exp '^' exp     { result = val[0].wedge(val[2]) }
     | exp '**' exp    { result = val[0].power(val[2]) }
     | '(' exp ')' '!' { result = function('fact', [val[1]]) }
     | '(' exp ')'     { result = val[1] }
     | '-' exp =UMINUS { result = val[1].neg }
     | exp '.' '(' args ')' { result = function(val[0], val[3]) }
     | func

  func: NAME '(' args ')' { result = function(val[0], val[2]) }
      | '#' '(' exp ')'   { result = function('sharp', [val[2]]) }
      | '#' func          { result = function('sharp', [val[1]]) }
      | '|' exp '|'       { result = function('abs', [val[1]]) }
      | NUMBER            { result = val[0].to_i.to_m }
      | NUMBER '!'        { result = function('fact', [val[0].to_i.to_m]) }
      | NAME              { result = named_node(val[0]) }
      | NAME '!'          { result = function('fact', [named_node(val[0])]) }

  args: args ',' exp { result = val[0].push(val[2]) }
      | exp          { result = [val[0]] }
end
---- header
require 'sy'

module Sy
---- inner
  attr_reader :exp

  def function(name, subnodes)
    args = subnodes

    if name.is_a?(String)
      # Syntactic sugar for 'flat' function
      name = 'flat' if name.eql?('b')

      if name.include? "'"
        raise ParseError, "\nparse error on function name '#{name}'"
      end

      if name == 'lmd'
        return Sy::Definition::Lmd.new(*args)
      end
    end

    return Sy::Operator.create(name, args.map { |a| a.nil? ? a : a })
  end

  # Create a variable or constant
  def named_node(name)
    if name.length >= 2 and name.match(/^d/)
      return name.to_sym.to_m('dform')
    end

    if name.match(/\'$/)
      name = name[0..-2]
      return name.to_sym.to_m('vector')
    end

    return name.to_sym.to_m
  end

  def parse(str)
    @q = []

    cmd = [
      'eval',
      'normalize',
      'expand',
      'factorize',
      'factorize_simple',
      'combine_fractions',
    ]

    until str.empty?
      case str
      when /\A\s+/
        # whitespace, do nothing
      when *cmd
        # command
        @q.push [:CMD, $&]
      when /\A[A-Za-z_]+[A-Za-z_0-9]*\'?/
        # name (char + (char|num))
        @q.push [:NAME, $&]
      when /\A\d+/
        # number (digits)
        @q.push [:NUMBER, $&]
      when /\A\*\*/
        # two character operators
        s = $&
        @q.push [s, s]
      when /\A.|\n/o
        # other signs
        s = $&
        @q.push [s, s]
      end
      str = $'
    end
    @q.push [false, '$end']
    exp = do_parse
    return if exp.nil?

    return exp
  end

  def next_token()
    @q.shift
  end
---- footer
end
