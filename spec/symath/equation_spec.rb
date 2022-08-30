require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Equation do

    define_fn(:ab, [:x])
    define_op(:cd, [:x])

    z = :z.to_m
    e1 = 'y + 2*x + 3 = 4'.to_m
    e2 = '2*y + 2*x + 1 = 2'.to_m
    e3 = '- y + x = 2'.to_m
    e1_clone = 'y + 2*x + 3 = 4'.to_m

    def1 = eq(:x.to_m, :y.to_m + 2)
    def2 = eq(fn(:ab, :b), :b)
    def3 = eq(op(:cd, :d), d(d(:d)))

    it 'compare equations' do
      expect(e1).to be == e1_clone
    end

    it 'adding' do
      expect((e1 + e3).normalize.to_s).to be == '3 x + 3 = 6'
      expect((e1 + 3).normalize.to_s).to be == 'y + 2 x + 6 = 7'
      expect((3 + e1).normalize.to_s).to be == 'y + 2 x + 6 = 7'
    end

    it 'subtracting' do
      expect((e1 - e2).normalize.to_s).to be == '- y + 2 = 2'
      expect((e1 - 3).normalize.to_s).to be == 'y + 2 x = 1'
      expect((3 - e1).normalize.to_s).to be == '- y - 2 x = - 1'
      expect((-e3).normalize.to_s).to be == 'y - x = - 2'
    end

    it 'multiplication' do
      expect { e1 * e2 }.to raise_error 'Cannot multiply two equations'
      expect((e1*2).normalize.to_s).to be == '2 (y + 2 x + 3) = 8'
      expect((z*e2).normalize.to_s).to be == 'z (2 y + 2 x + 1) = 2 z'
    end

    it 'division' do
      expect { e1 / e2 }.to raise_error 'Cannot divide by equation'
      expect((e1/3).normalize.to_s).to be == '(y + 2 x + 3)/3 = 4/3'
    end

    it 'power' do
      expect { e1**e2 }.to raise_error 'Cannot use equation as exponent'
      expect((e1**2).normalize.to_s).to be == '(y + 2 x + 3)**2 = 16'
    end
  end
end
