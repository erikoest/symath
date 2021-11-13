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
 
  define_fn(:myfun, [:x, :y])

  describe Sy::Parser do
    parse = {
      ''              => nil,
      '2'             => 2,
      'x'             => x.to_m,
      'x + y + z + 2' => x + y + z + 2,
      'x - y - z'     => x - y - z,
      '-x + 2'        => - x + 2,
      '2*x*y*z'       => 2*x*y*z,
      'x/y/z'         => (x/y).div(z),
      'x**y**z'       => (x**y).power(z),
      '(x+y)*(x+z)'   => (x + y)*(x + z),
      'sin(x)'        => sin(x),
      'myfun(x, y)'   => fn(:myfun, x, y),
      '(x + y)!'      => fact(x + y),
      'x!'            => fact(x),
      '123!'          => fact(123),
      'dx^dy^dz'      => ((dx^dy)^dz),
      "x'^y'^z'"      => ((xv^yv)^zv),
      '|x + y|'       => abs(x + y),
      '#dx'           => sharp(dx),
      '#(dx^dy)'      => sharp(dx^dy),
      'b(x*dx + dy)'  => flat(x*dx + dy),
    }

    parse.each do |from, to|
      it "parses '#{from}' into '#{to}'" do
        expect(from.to_m).to be_equal_to to
      end
    end

    error = {
      'myfun\'(x,y)' => 'parse error on function name myfun\'',
      'x + + y'      => 'parse error on value "+" ("+")',
    }

    error.each do |exp, error|
      it "fails to parse '#{exp}'" do
        expect { exp.to_m }.to raise_error(/error/)
      end
    end
  end
end
