require 'spec_helper'
require 'sy'

module Sy
  x = :x
  y = :y
  z = :z
  dx = :x.to_m('dform')
  dy = :y.to_m('dform')
  dz = :z.to_m('dform')
  xv = :x.to_m('vector')
  yv = :y.to_m('vector')
  zv = :z.to_m('vector')

  describe Sy::Parser do
    parse = {
      '2'             => 2,
      'x'             => x.to_m,
      'x + y + z + 2' => x + y + z + 2,
      'x - y - z'     => x - y - z,
      '-x + 2'        => - x + 2,
      '2*x*y*z'       => 2*x*y*z,
      'x/y/z'         => (x/y).div(z),
      'x**y**z'       => (x**y).power(z),
      '(x+y)*(x+z)'   => (x + y)*(x + z),
      'sin(x)'        => fn(:sin, x),
      'myfun(x, y)'   => fn(:myfun, x, y),
      '(x + y)!'      => fn(:fact, x + y),
      'x!'            => fn(:fact, x),
      '123!'          => fn(:fact, 123),
      'dx^dy^dz'      => ((dx^dy)^dz),
      "x'^y'^z'"      => ((xv^yv)^zv),
      '|x + y|'       => fn(:abs, x + y),
      '#dx'           => op(:sharp, dx),
      '#(dx^dy)'      => op(:sharp, dx^dy),
      'b(x*dx + dy)'  => op(:flat, x*dx + dy),
    }

    parse.each do |from, to|
      it "parses '#{from}' into '#{to}'" do
        expect(from.to_mexp).to be_equal_to to
      end
    end

    error = {
      'myfun\'(x,y)' => 'parse error on function name myfun\'',
      'x + + y'      => 'parse error on value "+" ("+")',
    }

    error.each do |exp, error|
      it "fails to parse '#{exp}'" do
        expect { exp.to_mexp }.to raise_error(/error/)
      end
    end
  end
end
