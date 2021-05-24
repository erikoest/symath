#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.15
# from Racc grammer file "".
#

require 'racc/parser.rb'

require 'sy'

module Sy
class Parser < Racc::Parser

module_eval(<<'...end parser.y/module_eval...', 'parser.y', 42)
  attr_reader :exp

  def function(name, subnodes)
    args = subnodes

    # If name is a built-in operator, create it rather than a function
    name = 'lower' if name.eql?('b')
      
    if Sy::Operator.is_builtin?(name.to_sym)
      return op(name, *args)
    else
      return fn(name, *args)
    end
  end

  # Create a variable or constant
  def named_node(name)
    if name.length >= 2 and name.match(/^d/)
      name = name[1..-1]
      return name.to_m('dform')
    end

    return name.to_m
  end
	
  def parse(str)
    @q = []

    until str.empty?
      case str
      when /\A\s+/
        # whitespace, do nothing
      when /(eval|normalize|expand|factorize|combine_fractions)/
        # command
        @q.push [:CMD, $&]
      when /\A[A-Za-z_]+[A-Za-z_0-9]*/
        # name (char + (char|num))
        @q.push [:NAME, $&]
      when /\A\d+(\.\d+)?/
        # number (digits.digits)
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
...end parser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    18,    15,    16,    17,    13,    14,    12,    18,    15,    16,
    17,    11,    38,    18,    15,    16,    17,    13,    14,    12,
    22,    23,    33,    18,    15,    16,    17,    13,    14,    12,
    39,     5,    41,     3,     4,    40,     7,     8,     9,    10,
     5,    25,     3,     4,    18,     7,     8,     9,    10,     5,
    18,     3,     4,    18,     7,     8,     9,    10,     5,   nil,
     3,     4,   nil,     7,     8,     9,    10,     5,   nil,     3,
     4,   nil,     7,     8,     9,    10,     5,   nil,     3,     4,
   nil,     7,     8,     9,    10,     5,   nil,     3,     4,   nil,
     7,     8,     9,    10,     5,   nil,     3,     4,   nil,     7,
     8,     9,    10,     5,   nil,     3,     4,   nil,     7,     8,
     9,    10,     5,   nil,     3,     4,   nil,     7,     8,     9,
    10,     5,   nil,     3,     4,   nil,     7,     8,     9,    10,
     5,   nil,     3,     4,   nil,     7,     8,     9,    10,     5,
   nil,     3,     4,    35,     7,     8,     9,    10,     5,   nil,
     3,     4,   nil,     7,     8,     9,    10,     5,   nil,     3,
     4,   nil,     7,     8,     9,    10,    18,    15,    16,    17,
    13,    14,    12,    18,    15,    16,    17,    13,    14,    12,
    18,    15,    16,    17,    13,    14,    12,    18,    15,    16,
    17,    13,    14,    18,    15,    16,    17,    13,    14,    18,
    15,    16,    17 ]

racc_action_check = [
    24,    24,    24,    24,    24,    24,    24,    27,    27,    27,
    27,     1,    24,    20,    20,    20,    20,    20,    20,    20,
     7,     8,    20,    37,    37,    37,    37,    37,    37,    37,
    36,     0,    37,     0,     0,    36,     0,     0,     0,     0,
     3,    11,     3,     3,    29,     3,     3,     3,     3,     4,
    30,     4,     4,    31,     4,     4,     4,     4,     5,   nil,
     5,     5,   nil,     5,     5,     5,     5,     9,   nil,     9,
     9,   nil,     9,     9,     9,     9,    12,   nil,    12,    12,
   nil,    12,    12,    12,    12,    13,   nil,    13,    13,   nil,
    13,    13,    13,    13,    14,   nil,    14,    14,   nil,    14,
    14,    14,    14,    15,   nil,    15,    15,   nil,    15,    15,
    15,    15,    16,   nil,    16,    16,   nil,    16,    16,    16,
    16,    17,   nil,    17,    17,   nil,    17,    17,    17,    17,
    18,   nil,    18,    18,   nil,    18,    18,    18,    18,    22,
   nil,    22,    22,    22,    22,    22,    22,    22,    23,   nil,
    23,    23,   nil,    23,    23,    23,    23,    40,   nil,    40,
    40,   nil,    40,    40,    40,    40,     2,     2,     2,     2,
     2,     2,     2,    34,    34,    34,    34,    34,    34,    34,
    42,    42,    42,    42,    42,    42,    42,    19,    19,    19,
    19,    19,    19,    26,    26,    26,    26,    26,    26,    28,
    28,    28,    28 ]

racc_action_pointer = [
    23,    11,   163,    32,    41,    50,   nil,     9,    10,    59,
   nil,    41,    68,    77,    86,    95,   104,   113,   122,   184,
    10,   nil,   131,   140,    -3,   nil,   190,     4,   196,    41,
    47,    50,   nil,   nil,   170,   nil,    18,    20,   nil,   nil,
   149,   nil,   177 ]

racc_action_default = [
    -2,   -22,    -1,   -22,   -22,   -22,   -13,   -19,   -22,   -22,
   -18,   -22,   -22,   -22,   -22,   -22,   -22,   -22,   -22,    -3,
   -22,   -12,   -22,   -22,   -22,    43,    -4,    -5,    -6,    -7,
    -8,    -9,   -10,   -11,   -21,   -14,   -22,   -22,   -17,   -15,
   -22,   -16,   -20 ]

racc_goto_table = [
     2,     1,    36,    19,    20,    21,   nil,   nil,   nil,    24,
   nil,   nil,    26,    27,    28,    29,    30,    31,    32,   nil,
   nil,   nil,    34,    37,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
    42 ]

racc_goto_check = [
     2,     1,     4,     2,     2,     2,   nil,   nil,   nil,     2,
   nil,   nil,     2,     2,     2,     2,     2,     2,     2,   nil,
   nil,   nil,     2,     2,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
     2 ]

racc_goto_pointer = [
   nil,     1,     0,   nil,   -20 ]

racc_goto_default = [
   nil,   nil,   nil,     6,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 19, :_reduce_none,
  0, 19, :_reduce_2,
  2, 20, :_reduce_3,
  3, 20, :_reduce_4,
  3, 20, :_reduce_5,
  3, 20, :_reduce_6,
  3, 20, :_reduce_7,
  3, 20, :_reduce_8,
  3, 20, :_reduce_9,
  3, 20, :_reduce_10,
  3, 20, :_reduce_11,
  2, 20, :_reduce_12,
  1, 20, :_reduce_none,
  3, 21, :_reduce_14,
  4, 21, :_reduce_15,
  4, 21, :_reduce_16,
  3, 21, :_reduce_17,
  1, 21, :_reduce_18,
  1, 21, :_reduce_19,
  3, 22, :_reduce_20,
  1, 22, :_reduce_21 ]

racc_reduce_n = 22

racc_shift_n = 43

racc_token_table = {
  false => 0,
  :error => 1,
  :UMINUS => 2,
  "**" => 3,
  "*" => 4,
  "/" => 5,
  "^" => 6,
  "+" => 7,
  "-" => 8,
  "=" => 9,
  :CMD => 10,
  "(" => 11,
  ")" => 12,
  :NAME => 13,
  "#" => 14,
  "|" => 15,
  :NUMBER => 16,
  "," => 17 }

racc_nt_base = 18

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
  "\"+\"",
  "\"-\"",
  "\"=\"",
  "CMD",
  "\"(\"",
  "\")\"",
  "NAME",
  "\"#\"",
  "\"|\"",
  "NUMBER",
  "\",\"",
  "$start",
  "target",
  "exp",
  "func",
  "args" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

module_eval(<<'.,.,', 'parser.y', 13)
  def _reduce_2(val, _values, result)
     result = nil 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 14)
  def _reduce_3(val, _values, result)
     result = val[1].send(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 15)
  def _reduce_4(val, _values, result)
     result = Sy::Equation(val[0], val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 16)
  def _reduce_5(val, _values, result)
     result = val[0].add(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 17)
  def _reduce_6(val, _values, result)
     result = val[0].sub(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 18)
  def _reduce_7(val, _values, result)
     result = val[0].mul(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 19)
  def _reduce_8(val, _values, result)
     result = val[0].div(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 20)
  def _reduce_9(val, _values, result)
     result = val[0].wedge(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 21)
  def _reduce_10(val, _values, result)
     result = val[0].power(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 22)
  def _reduce_11(val, _values, result)
     result = val[1] 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 23)
  def _reduce_12(val, _values, result)
     result = val[1].neg 
    result
  end
.,.,

# reduce 13 omitted

module_eval(<<'.,.,', 'parser.y', 26)
  def _reduce_14(val, _values, result)
     result = function(val[0], []) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 27)
  def _reduce_15(val, _values, result)
     result = function(val[0], val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 28)
  def _reduce_16(val, _values, result)
     result = function('sharp', [val[2]]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 29)
  def _reduce_17(val, _values, result)
     result = function('abs', [val[1]]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 30)
  def _reduce_18(val, _values, result)
     result = val[0].to_i.to_m 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 31)
  def _reduce_19(val, _values, result)
     result = named_node(val[0]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 33)
  def _reduce_20(val, _values, result)
     result = val[0].push(val[2]) 
    result
  end
.,.,

module_eval(<<'.,.,', 'parser.y', 34)
  def _reduce_21(val, _values, result)
     result = [val[0]] 
    result
  end
.,.,

def _reduce_none(val, _values, result)
  val[0]
end

end   # class Parser

end
