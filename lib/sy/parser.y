# Sy expression parser

class Parser
  prechigh
    nonassoc UMINUS
    left '**'
    left '*' '/' '^'
    left '+' '-'
    left '='
  preclow
rule
  target: exp
      | /* none */     { result = 0 }
  exp: exp '=' exp     { result = operator('Sy::Equation', [val[0], val[2]], val[0]) }
     | exp '+' exp     { result = operator('Sy::Sum', [val[0], val[2]], val[0]) }
     | exp '-' exp     { result = operator('Sy::Subtraction', [val[0], val[2]], val[0]) }
     | exp '*' exp     { result = operator('Sy::Product', [val[0], val[2]], val[0]) }
     | exp '/' exp     { result = operator('Sy::Fraction', [val[0], val[2]], val[0]) }
     | exp '^' exp     { result = operator('Sy::Wedge', [val[0], val[2]], val[0]) }
     | exp '**' exp    { result = operator('Sy::Power', [val[0], val[2]], val[0]) }
     | '(' exp ')'     { result = val[1] }
     | '-' exp =UMINUS { result = operator('Sy::Minus', [val[1]], val[0]) }
     | func

  func: NAME '(' ')'      { result = function(val[0], []) }
      | NAME '(' args ')' { result = function(val[0], val[2]) }
      | '#' '(' exp ')'   { result = function('sharp', [val[2]]) }
      | '|' exp '|'       { result = function('abs', [val[1]]) }
      | NUMBER            { result = leaf('Sy::Number', val[0]) }
      | NAME              { result = self.named_value(val[0]) }

  args: args ',' exp { result = val[0].push(val[2]) }
      | exp          { result = [val[0]] }
end
---- header
require 'sy'
require 'sy/node'

module Sy
---- inner
  attr_reader :exp

  def named_value(node)
if (node.val.match(/^(pi|e|i)$/)) then
      return leaf('Sy::ConstantSymbol', node)
    end
    return leaf('Sy::Variable', node)
  end

  def operator(clazz, subnodes, pos)
    args = subnodes.map { |s| s.val }
    paths = [Sy::Path.new([], pos.paths[0].pos)]
    (0...subnodes.length).to_a.each { |i| paths += subnodes[i].paths.map { |p| p.unshift(i) } }
    return Sy::Node.new(Kernel.const_get(clazz).new(*args), paths)
  end

  def function(name, subnodes)
    args = subnodes.map { |s| s.val }
    paths = name.paths.clone
    (0...subnodes.length).to_a.each { |i| paths += subnodes[i].paths.map { |p| p.unshift(i) } }

    # If name is a built-in operator, create it rather than a function
    if Sy::Operator.builtin_operators.member?(name.val.to_sym)
      return Sy::Node.new(op(name.val, *args), paths)
    end

    return Sy::Node.new(Sy::Function.new(name.val, args), paths)
  end

  def leaf(clazz, name)
    if clazz.eql?('Sy::Variable')
      n = name.val
      t = 'real'
     if n =~ /^d/
       n = n[1..-1]
       t = 'dform'
     end
     return Sy::Node.new(Sy::Variable.new(n,t), name.paths)
    end
    
    return Sy::Node.new(Kernel.const_get(clazz).new(name.val), name.paths)
  end

  def parse(str)
    @q = []

    pos = 0
    until str.empty?
      case str
      when /\A\s+/
        # whitespace, do nothing
      when /\A[A-Za-z_]+[A-Za-z_0-9]*/
        # name (char + (char|num))
        @q.push [:NAME, Sy::Node.new($&, [Sy::Path.new([], pos)])]
      when /\A\d+(\.\d+)?/
        # number (digits.digits)
        @q.push [:NUMBER, Sy::Node.new($&, [Sy::Path.new([], pos)])]
      when /\A\*\*/
        # two character operators
        s = $&
        @q.push [s, Sy::Node.new(s, [Sy::Path.new([], pos)])]
      when /\A.|\n/o
        # other signs
        s = $&
        @q.push [s, Sy::Node.new(s, [Sy::Path.new([], pos)])]
      end
      pos += str.length - $'.length
      str = $'
    end
    @q.push [false, '$end']
    nodes = do_parse
    return if nodes == 0

    @paths = nodes.paths
    @exp = nodes.val
    # dump_paths

    return nodes.val
  end

  def dump_paths
    @paths.each do |p|
      puts sprintf("%d %s %s", p.pos, p.path, @val.seek(p).to_s)
    end
  end

  def paths_by_position(pos)
    # find highest position < pos
    highest = @paths.map { |p| p.pos <= pos ? p.pos : 0 }.max
    # return all paths having the highest position (can be multiple)
    return @paths.select { |p| p.pos == highest }.sort
  end
  
  def next_token()
    @q.shift
  end
---- footer
end
