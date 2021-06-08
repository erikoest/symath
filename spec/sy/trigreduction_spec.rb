require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', trigreduction' do
    exp = {
      fn(:sin, 0)                  => 0.to_m,
      fn(:sin, :pi/6)               => 1.to_m/2,
      fn(:sin, 17*:pi/6)           => 1.to_m/2,
      fn(:sin, -23*:pi/4)          => fn(:sqrt, 2)/2,
      fn(:cos, 0)                  => 1.to_m,
      fn(:cos, 3*:pi/4)            => - fn(:sqrt, 2)/2,
      fn(:tan, 0)                  => 0.to_m,
      fn(:tan, :pi/4)              => 1.to_m,
      fn(:cot, -:pi/6)             => - fn(:sqrt, 3),
      fn(:sec, 0)                  => 1.to_m,
      fn(:sec, :pi/4)              => fn(:sqrt, 2)/2,
      fn(:csc, 0)                  => 1.to_m,
      fn(:csc, 3*:pi/4)            => - fn(:sqrt, 2)/2,
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end

    nored = [
      fn(:sin, :pi/14),
      fn(:cos, -:pi/5),
      fn(:tan, :pi/2),
      fn(:tan, -3.to_m*:pi/9),
      fn(:cot, 0),
      fn(:cot, -17.to_m*:pi/5),
      fn(:sec, 3*:pi/11),
      fn(:csc, -3*:pi/13),
    ];

    nored.each do |n|
      it "does not reduce '#{n.to_s}'" do
        expect(n.normalize).to be_equal_to n
      end
    end
  end
end
