# SyMath expression parser

## TOODO
## |a>@|b> (outer product, explicitly)
## <bra|(|ket>) (== <bra|ket>)
## hermitian operation (which symbol to use for the dagger)

class Parser
  prechigh
    nonassoc UMINUS
    left '**'
    left '*' '/' '^' '×'
    left '+' '-'
    left '='
    left '|'
    unassoc '.'
    CMD
  preclow
  expect 1
rule
  target: exp
     | /* none */       { return nil }
  exp: CMD exp          { return val[1].send(val[0]) }
     | exp '=' exp      { return eq(val[0], val[2]) }
     | exp '+' prod     { return val[0].add(val[2]) }
     | exp '-' prod     { return val[0].sub(val[2]) }
     | prod             { return val[0] }
     | '-' prod =UMINUS { return val[1].neg }

  prod: prod '/' factor { return val[0].div(val[2]) }
      | prod '*' factor { return val[0].mul(val[2]) }
      | prod '^' factor { return val[0].wedge(val[2]) }
      | prod '×' factor { return val[0].outer(val[2]) }
      | prod factor     { return val[0].mul(val[1]) }
      | factor          { return val[0] }

  factor: factor '**' factor      { return val[0].power(val[2]) }
        | factor '**' '-' factor  { return val[0].power(val[3].neg) }
        | '(' exp ')' '!'         { return function('fact', [val[1]]) }
        | '(' exp ')'             { return val[1] }
        | '|' factor '|'          { return function('abs', [val[1]]) }
        | factor '.' '(' args ')' { return function(val[0], val[3]) }
        | func

  func: NAME '(' args ')' { return function(val[0], val[2]) }
      | '#' '(' exp ')'   { return function('sharp', [val[2]]) }
      | '#' func          { return function('sharp', [val[1]]) }
      | NUMBER            { return val[0].to_i.to_m }
      | NUMBER '!'        { return function('fact', [val[0].to_i.to_m]) }
      | NAME              { return named_node(val[0]) }
      | NAME '!'          { return function('fact', [named_node(val[0])]) }
      | braket            { return val[0] }

  args: args ',' exp { return val[0].push(val[2]) }
      | exp          { return [val[0]] }

  braket: bra blist '>' { return val[0].mul(vector_node(val[1])) }
        | bra           { return val[0] }
        | ket           { return val[0] }

  bra: '<' blist '|' { return covector_node(val[1]) }

  ket: '|' blist '>' { return vector_node(val[1]) }

  blist: BSYM ',' blist { return [ val[0] ] + val[2] }
       | BSYM           { return [ val[0] ] }

end
---- header
require 'symath'

module SyMath

class TokenQueue
  def initialize()
    @queue = []
    @history = []

    @bra = false
    @ket = false
    @braket_queue = []
  end

  def push_braket_queue(inside_braket)
    @braket_queue.each do |a|
      if inside_braket
        if [:NUMBER, :NAME, '-', '+'].include?(a[0])
          a[0] = :BSYM
          a[1] = a[1].to_s
        end
      end

      @queue.push(a)
    end

    @braket_queue = []
  end

  def push(t, val)
    # Starting a bra
    if t == '<'
      @braket_queue.push([t, val])
      push_braket_queue(false)
      @bra = true
      return
    end

    # Ending a bra and starting a ket
    if t == '|'
      @braket_queue.push([t, val])
      if @bra
        push_braket_queue(true)
        @bra = false
      end

      if @ket
        push_braket_queue(false)
      end

      @ket = true
      return
    end

    # Ending a ket
    if t == '>'
      @braket_queue.push([t, val])
      if @ket
        push_braket_queue(true)
	@ket = false
      else
	push_braket_queue(false)
      end
      return
    end

    if @bra or @ket
      @braket_queue.push([t, val])
    else
      @queue.push([t, val])
    end
  end

  def finish_queue
    push_braket_queue(false)
    @queue.push([false, '$end'])
  end

  def shift
    last = @queue.shift
    @history.push(last)
    return last
  end

  def previous(i = -1)
    return @history[i]
  end

  def debug_dump()
    puts @queue.map { |a| a[0] }.join(' ')
  end
end

---- inner
  attr_reader :exp

  def function(name, subnodes)
    args = subnodes

    if name.is_a?(String)
      # Syntactic sugar for 'flat' function
      name = 'flat' if name.eql?('b')

      if name.include? "'"
        raise ParseError, "\nparse error on value '#{@q.previous(-2)}'"
      end

      if name == 'lmd'
        return SyMath::Definition::Lmd.new(*args)
      end
    end

    return SyMath::Operator.create(name, args.map { |a| a.nil? ? a : a })
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

  def norm_bsymbols(blist)
    return blist.map do |a|
      if a =~ /\A[0-9]\Z$/
        a = 'q' + a
      elsif a == '-'
        a = 'qminus'
      elsif a == '+'
        a = 'qpluss'
      end
      a
    end
  end

  def covector_node(list)
    return norm_bsymbols(list).map { |a|
      a.to_sym.to_m('covector')
    }.inject(:outer)
  end

  def vector_node(list)
    return norm_bsymbols(list).map { |a|
      a.to_sym.to_m('vector')
    }.inject(:outer)
  end

  def parse(str)
    @last_token = nil
    @current_token = nil
    @q = SyMath::TokenQueue.new()

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
        @q.push(:CMD, $&)
      when /\A[A-Za-z_]+[A-Za-z_0-9]*\'?/
        # name (char + (char|num))
        @q.push(:NAME, $&)
      when /\A\d+/
        # number (digits)
        @q.push(:NUMBER, $&)
      when /\A\*\*/
        # two character operators
        s = $&
        @q.push(s, s)
      when /\A.|\n/o
        # other signs
        s = $&
        @q.push(s, s)
      end
      str = $'
    end
    @q.finish_queue
#    @q.debug_dump

    exp = do_parse
    return if exp.nil?

    return exp
  end

  def next_token()
    return @q.shift
  end
---- footer
end
