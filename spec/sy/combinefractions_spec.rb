require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Normalization.new

  describe Sy::CombineFractions do
    sums = {
      1.to_m                               => '1',
      2.to_m                               => '2',
      :a.to_m                              => 'a',
      :a.to_m/2                            => 'a/2',
      :a.to_m/:b                           => 'a/b',
      2.to_m/:a                            => '2/a',
      :a.to_m/:c + :b.to_m/:c              => '(a + b)/c',
      2.to_m/3 + 3.to_m/4                  => '17/12',
      :a.to_m/2 + 2.to_m*:a/3              => '7*a/6',
      2.to_m*:a/:b + 2.to_m*:c/(3.to_m*:b) => '(6*a + 2*c)/(3*b)',
    }

    sums.each do |from, to|
      it "combines '#{from.to_s}' to '#{to}'" do
        n.act(op(:combfrac, from).act).to_s.should == to
      end
    end
  end
end
