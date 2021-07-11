require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', reduce exp and ln' do
    exp = {
      fn(:exp, 0)                      => 1,
      fn(:exp, fn(:ln, :a))            => :a.to_m,
      fn(:exp, -fn(:ln, :a))           => 1/:a,
      fn(:exp, :pi*:i/2)               => :i,
      fn(:exp, :pi*:i)                 => -1,
      fn(:exp, 3*:pi*:i/2)             => -:i,
      fn(:exp, 2*:pi*:i)               => 1,
      fn(:exp, -:pi*:i/2)              => -:i,
      fn(:exp, -2*:pi*:i)              => 1,
      fn(:exp, -7*:pi*:i/2)            => :i,
      fn(:exp, :pi*:i/2 - fn(:ln, :a)) => :i/:a,
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end

    nored = [
      fn(:exp, :pi/3),
      fn(:exp, -:pi*:a),
      fn(:exp, sin(:a)),
      fn(:exp, ln(:b) + 4),
      fn(:exp, 2),
      fn(:exp, ln(:f) + :pi*:i/3),
    ];

    nored.each do |n|
      it "does not reduce '#{n.to_s}'" do
        expect(n.normalize).to be_equal_to n
      end
    end
  end
end
