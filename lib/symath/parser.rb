#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.5.0
# from Racc grammar file "".
#

require 'racc/parser.rb'

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

class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 164)
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
        a = 'qplus'
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
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    23,    22,    24,    25,    19,    20,    18,     8,    28,    19,
    20,     7,    53,    17,    10,    11,    12,    39,    29,    16,
    23,    22,    24,    25,    19,    20,    18,     8,    28,    33,
    33,     7,    68,    42,    10,    11,    12,    52,    29,    16,
    23,    22,    24,    25,    66,    69,    34,     8,    35,    67,
    67,     7,    55,    56,    10,    11,    12,    33,    28,    16,
    23,    22,    24,    25,    60,    61,    54,     8,    29,    64,
    33,     7,    28,    28,    10,    11,    12,   nil,     5,    16,
     8,   nil,    29,     3,     7,    28,   nil,    10,    11,    12,
   nil,     5,    16,     8,   nil,    29,     3,     7,    28,   nil,
    10,    11,    12,   nil,     5,    16,     8,   nil,    29,     3,
     7,    28,   nil,    10,    11,    12,   nil,     5,    16,     8,
   nil,    29,     3,     7,   nil,   nil,    10,    11,    12,   nil,
    51,    16,     8,    19,    20,    18,     7,   nil,   nil,    10,
    11,    12,   nil,     5,    16,     8,   nil,   nil,     3,     7,
   nil,   nil,    10,    11,    12,   nil,     5,    16,     8,   nil,
   nil,     3,     7,   nil,   nil,    10,    11,    12,   nil,     5,
    16,     8,   nil,   nil,     3,     7,   nil,   nil,    10,    11,
    12,   nil,     5,    16,     8,   nil,   nil,     3,     7,   nil,
     8,    10,    11,    12,     7,   nil,    16,    10,    11,    12,
     8,   nil,    16,    33,     7,   nil,    38,    10,    11,    12,
    36,   nil,    16,    10,    11,    12,     8,   nil,    16,   nil,
     7,   nil,     8,    10,    11,    12,     7,   nil,    16,    10,
    11,    12,     8,   nil,    16,   nil,     7,   nil,     8,    10,
    11,    12,     7,   nil,    16,    10,    11,    12,     8,   nil,
    16,   nil,     7,   nil,     8,    10,    11,    12,     7,   nil,
    16,    10,    11,    12,     8,   nil,    16,   nil,     7,   nil,
   nil,    10,    11,    12,   nil,   nil,    16,    19,    20,    18,
    19,    20,    18,    19,    20,    18 ]

racc_action_check = [
     4,     4,     4,     4,    30,    30,    30,     4,     6,    43,
    43,     4,    30,     1,     4,     4,     4,    12,     6,     4,
    27,    27,    27,    27,    59,    59,    59,    27,    26,    14,
    16,    27,    59,    17,    27,    27,    27,    29,    26,    27,
    44,    44,    44,    44,    58,    63,    10,    44,    10,    58,
    63,    44,    32,    33,    44,    44,    44,    38,    31,    44,
    45,    45,    45,    45,    40,    41,    31,    45,    31,    53,
    56,    45,    46,    62,    45,    45,    45,   nil,     0,    45,
     0,   nil,    46,     0,     0,    47,   nil,     0,     0,     0,
   nil,     3,     0,     3,   nil,    47,     3,     3,    48,   nil,
     3,     3,     3,   nil,     7,     3,     7,   nil,    48,     7,
     7,    49,   nil,     7,     7,     7,   nil,    18,     7,    18,
   nil,    49,    18,    18,   nil,   nil,    18,    18,    18,   nil,
    28,    18,    28,     2,     2,     2,    28,   nil,   nil,    28,
    28,    28,   nil,    34,    28,    34,   nil,   nil,    34,    34,
   nil,   nil,    34,    34,    34,   nil,    36,    34,    36,   nil,
   nil,    36,    36,   nil,   nil,    36,    36,    36,   nil,    52,
    36,    52,   nil,   nil,    52,    52,   nil,   nil,    52,    52,
    52,   nil,    67,    52,    67,   nil,   nil,    67,    67,   nil,
     8,    67,    67,    67,     8,   nil,    67,     8,     8,     8,
     5,   nil,     8,     8,     5,   nil,    11,     5,     5,     5,
    11,   nil,     5,    11,    11,    11,    19,   nil,    11,   nil,
    19,   nil,    20,    19,    19,    19,    20,   nil,    19,    20,
    20,    20,    22,   nil,    20,   nil,    22,   nil,    23,    22,
    22,    22,    23,   nil,    22,    23,    23,    23,    24,   nil,
    23,   nil,    24,   nil,    25,    24,    24,    24,    25,   nil,
    24,    25,    25,    25,    51,   nil,    25,   nil,    51,   nil,
   nil,    51,    51,    51,   nil,   nil,    51,    21,    21,    21,
    57,    57,    57,    70,    70,    70 ]

racc_action_pointer = [
    69,    13,   125,    82,    -4,   189,     5,    95,   179,   nil,
    31,   195,     0,   nil,     5,   nil,     6,    33,   108,   205,
   211,   269,   221,   227,   237,   243,    25,    16,   121,    22,
    -4,    55,    30,    32,   134,   nil,   147,   nil,    33,   nil,
    42,    54,   nil,     1,    36,    56,    69,    82,    95,   108,
   nil,   253,   160,    52,   nil,   nil,    46,   272,    28,    16,
   nil,   nil,    70,    29,   nil,   nil,   nil,   173,   nil,   nil,
   275 ]

racc_action_default = [
    -2,   -39,    -1,   -39,    -7,   -39,   -14,   -39,   -39,   -21,
   -27,   -39,   -25,   -29,   -33,   -34,   -39,   -39,   -39,   -39,
   -39,    -3,   -39,   -39,   -39,   -39,   -13,    -8,   -39,   -39,
   -39,   -39,   -39,   -38,   -39,   -28,   -39,   -24,   -39,   -26,
   -39,   -39,    71,    -4,    -5,    -6,    -9,   -10,   -11,   -12,
   -15,   -39,   -39,   -18,   -19,   -36,   -39,   -31,   -39,   -39,
   -32,   -35,   -16,   -39,   -17,   -37,   -22,   -39,   -23,   -20,
   -30 ]

racc_goto_table = [
     2,    26,    40,    21,    41,    31,     1,    30,    58,    37,
   nil,   nil,   nil,    27,   nil,   nil,   nil,   nil,    43,    46,
    47,    48,    49,   nil,    26,    50,    63,    44,    45,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,    59,   nil,   nil,   nil,
   nil,    26,    26,   nil,    65,   nil,   nil,   nil,    62,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    70 ]

racc_goto_check = [
     2,     4,     9,     2,     9,     4,     1,     2,     5,     6,
   nil,   nil,   nil,     3,   nil,   nil,   nil,   nil,     2,     4,
     4,     4,     4,   nil,     4,     4,     5,     3,     3,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,     2,   nil,   nil,   nil,
   nil,     4,     4,   nil,     9,   nil,   nil,   nil,     4,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,     2 ]

racc_goto_pointer = [
   nil,     6,     0,     8,    -3,   -26,    -2,   nil,   nil,   -12,
   nil ]

racc_goto_default = [
   nil,   nil,    57,     4,     6,   nil,     9,    13,    14,    32,
    15 ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 26, :_reduce_none,
  0, 26, :_reduce_2,
  2, 27, :_reduce_3,
  3, 27, :_reduce_4,
  3, 27, :_reduce_5,
  3, 27, :_reduce_6,
  1, 27, :_reduce_7,
  2, 27, :_reduce_8,
  3, 28, :_reduce_9,
  3, 28, :_reduce_10,
  3, 28, :_reduce_11,
  3, 28, :_reduce_12,
  2, 28, :_reduce_13,
  1, 28, :_reduce_14,
  3, 29, :_reduce_15,
  4, 29, :_reduce_16,
  4, 29, :_reduce_17,
  3, 29, :_reduce_18,
  3, 29, :_reduce_19,
  5, 29, :_reduce_20,
  1, 29, :_reduce_none,
  4, 31, :_reduce_22,
  4, 31, :_reduce_23,
  2, 31, :_reduce_24,
  1, 31, :_reduce_25,
  2, 31, :_reduce_26,
  1, 31, :_reduce_27,
  2, 31, :_reduce_28,
  1, 31, :_reduce_29,
  3, 30, :_reduce_30,
  1, 30, :_reduce_31,
  3, 32, :_reduce_32,
  1, 32, :_reduce_33,
  1, 32, :_reduce_34,
  3, 33, :_reduce_35,
  3, 35, :_reduce_36,
  3, 34, :_reduce_37,
  1, 34, :_reduce_38 ]

racc_reduce_n = 39

racc_shift_n = 71

racc_token_table = {
  false => 0,
  :error => 1,
  :UMINUS => 2,
  "**" => 3,
  "*" => 4,
  "/" => 5,
  "^" => 6,
  "\xC3\x97" => 7,
  "+" => 8,
  "-" => 9,
  "=" => 10,
  "|" => 11,
  :unassoc => 12,
  "." => 13,
  :CMD => 14,
  "(" => 15,
  ")" => 16,
  "!" => 17,
  :NAME => 18,
  "#" => 19,
  :NUMBER => 20,
  "," => 21,
  ">" => 22,
  "<" => 23,
  :BSYM => 24 }

racc_nt_base = 25

racc_use_result_var = true

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "UMINUS",
  "\"**\"",
  "\"*\"",
  "\"/\"",
  "\"^\"",
  "\"\\xC3\\x97\"",
  "\"+\"",
  "\"-\"",
  "\"=\"",
  "\"|\"",
  "unassoc",
  "\".\"",
  "CMD",
  "\"(\"",
  "\")\"",
  "\"!\"",
  "NAME",
  "\"#\"",
  "NUMBER",
  "\",\"",
  "\">\"",
  "\"<\"",
  "BSYM",
  "$start",
  "target",
  "exp",
  "prod",
  "factor",
  "args",
  "func",
  "braket",
  "bra",
  "blist",
  "ket" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'parser.y', 21)
  def _reduce_2(val, _values, result)
     return nil
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 22)
  def _reduce_3(val, _values, result)
     return val[1].send(val[0])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 23)
  def _reduce_4(val, _values, result)
     return eq(val[0], val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 24)
  def _reduce_5(val, _values, result)
     return val[0].add(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 25)
  def _reduce_6(val, _values, result)
     return val[0].sub(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 26)
  def _reduce_7(val, _values, result)
     return val[0]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 27)
  def _reduce_8(val, _values, result)
     return val[1].neg
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 29)
  def _reduce_9(val, _values, result)
     return val[0].div(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 30)
  def _reduce_10(val, _values, result)
     return val[0].mul(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 31)
  def _reduce_11(val, _values, result)
     return val[0].wedge(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 32)
  def _reduce_12(val, _values, result)
     return val[0].outer(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 33)
  def _reduce_13(val, _values, result)
     return val[0].mul(val[1])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 34)
  def _reduce_14(val, _values, result)
     return val[0]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 36)
  def _reduce_15(val, _values, result)
     return val[0].power(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 37)
  def _reduce_16(val, _values, result)
     return val[0].power(val[3].neg)
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 38)
  def _reduce_17(val, _values, result)
     return function('fact', [val[1]])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 39)
  def _reduce_18(val, _values, result)
     return val[1]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 40)
  def _reduce_19(val, _values, result)
     return function('abs', [val[1]])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 41)
  def _reduce_20(val, _values, result)
     return function(val[0], val[3])
    result
  end
.,.,

# reduce 21 omitted

module_eval(<<'.,.,', 'parser.y', 44)
  def _reduce_22(val, _values, result)
     return function(val[0], val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 45)
  def _reduce_23(val, _values, result)
     return function('sharp', [val[2]])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 46)
  def _reduce_24(val, _values, result)
     return function('sharp', [val[1]])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 47)
  def _reduce_25(val, _values, result)
     return val[0].to_i.to_m
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 48)
  def _reduce_26(val, _values, result)
     return function('fact', [val[0].to_i.to_m])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 49)
  def _reduce_27(val, _values, result)
     return named_node(val[0])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 50)
  def _reduce_28(val, _values, result)
     return function('fact', [named_node(val[0])])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 51)
  def _reduce_29(val, _values, result)
     return val[0]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 53)
  def _reduce_30(val, _values, result)
     return val[0].push(val[2])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 54)
  def _reduce_31(val, _values, result)
     return [val[0]]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 56)
  def _reduce_32(val, _values, result)
     return val[0].mul(vector_node(val[1]))
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 57)
  def _reduce_33(val, _values, result)
     return val[0]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 58)
  def _reduce_34(val, _values, result)
     return val[0]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 60)
  def _reduce_35(val, _values, result)
     return covector_node(val[1])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 62)
  def _reduce_36(val, _values, result)
     return vector_node(val[1])
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 64)
  def _reduce_37(val, _values, result)
     return [ val[0] ] + val[2]
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 65)
  def _reduce_38(val, _values, result)
     return [ val[0] ]
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

end   # class Parser

end
