require 'spec_helper'
require 'symath'

module SyMath
  x = :x
  y = :y
  z = :z
  dx = :dx.to_m('form')
  dy = :dy.to_m('form')
  dz = :dz.to_m('form')
  xv = :xv.to_m('vector')
  yv = :yv.to_m('vector')
  zv = :zv.to_m('vector')
 
  define_fn(:myfun, [:x, :y])

  describe SyMath::Parser do
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
      "xv'^yv'^zv'"   => ((xv^yv)^zv),
      '|(x + y)|'     => abs(x + y),
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
