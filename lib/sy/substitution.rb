# coding: iso-8859-1
require 'sy/parser'

module Sy
  class Substitution
    attr_reader :before, :after, :position
    attr_reader :match_count

    def initialize(before, after, position)
      @before = before
      @after = after
      @position = position
    end

    def found_all_matches()
      return false if @position == 'a'
      return @match_count > @position
    end
    
    def match_is_within_range()
      return true if (@position == 'a')
      return @match_count == @position
    end

    def perform_node(expr)
      # Perform substitution on expression node
      # Recurse through the expression.
      # 1. perform substitution on each of the sub expressions
      expr.nodes = expr.nodes.map do |n|
        if (self.found_all_matches) then
          n
        else
          self.perform_node(n)
        end
      end
      
      return expr if self.found_all_matches
      
      # If expression does not match, we are done
      varmap = @before.match(expr, {})

      # Found match. Store variable mapping from match.
      return expr if !varmap

      newex = expr
      
      if self.match_is_within_range() then
        # Match is within range for substitution. Replace expression
        # with substitution right hand side expression, using the
        # variable mapping

        newex = after.clone
        newex.replace(varmap)
      end
      
      # Count up matches
      @match_count += 1
      return newex
    end
    
    def perform(expr)
      @match_count = 0
      newex = self.perform_node(expr)
      return newex
    end

    def self.list_rules
      p = Sy::Parser.new

      # Andre substitusjonsregler:
      # a + a + ... + a -> n*a
      # a*a*...*a -> a^n
      # a*b + a*c -> a*(b + c)

      # Normaliseringer:
      # a*(b + c + ... + d) -> a*b + a*c + ... + a*d
      # (a*-b*-c*d*-e) -> -(a*b*c*d*e)
      # 1/a*b -> a/b

      # FIXME: Substitusjoner på multivariabelfunksjoner der
      # (a o b) o c = a o (b o c)
      # Her må substitusjoner av typen a o b matche både a o b og b o c.
      # I tillegg a o c og speilvendingene b o a, c o b, c o a hvis
      # funksjonen kommuterer.

      # FIXME: Vi trenger å kunne spesifisere hva en variabel kan representere:
      # - numerisk konstant
      # - hvilket som helst uttrykk
      # Andre begrensninger:
      # - noden er en bestemt type (vektor, matrise, komplekst tall, reelt tall
      # - heltall)
      # - positivt tall, partall eller oddetall, primtall,imaginært
      # 
      # F.eks
      # f(a, b) -> 0 | a:prime,real,imag b:even

      # Er det mulig å bestemme type på en node (heltall, komplekst tall,
      # matrise, vektor, differensiell form.

      # Hvordan skille mellom operatorer og funksjoner

      return ['0/a -> 0',
              'a/1 -> a',
              'a/a -> 1',
              '-(-a) -> a',
              'a^0 -> 1',
              'a^1 -> a',
              'ln(e^a) -> a',
              'sin(-2*pi) -> 0',
              'sin(-3/2*pi) -> 1',
              'sin(-pi) -> 0',
              'sin(-pi/2) -> -1',
              'sin(0) -> 0',
              'sin(pi/2) -> 1',
              'sin(pi) -> 0',
              'sin(3/2*pi) -> -1',
              'sin(2*pi) -> 1',
              'cos(-2*pi) -> 1',
              'cos(-3/2*pi) -> 0',
              'cos(-pi) -> -1',
              'cos(-pi/2) -> 0',
              'cos(0) -> 1',
              'cos(pi/2) -> 0',
              'cos(pi) -> -1',
              'cos(3/2*pi) -> 0',
              'cos(2*pi) -> 1',
              'tan(-2*pi) -> 0',
              'tan(-5/4*pi) -> 1',
              'tan(-pi) -> 0',
              'tan(-3/4*pi) -> -1',
              'tan(0) -> 0',
              'tan(pi/4) -> 1',
              'tan(3/4*pi) -> -1',
              'tan(pi) -> 0',
              'tan(5/4*pi) -> 1',
              'tan(2*pi) -> 0',
             ].map do |str|
        p.parse(str)
      end
    end

    def to_s()
      str = @before.to_s + ' -> ' + @after.to_s
      if (@position != 'a') then
        str += ' at position ' + @position
      end

      return str
    end
  end
end
