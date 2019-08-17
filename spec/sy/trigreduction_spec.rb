require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::TrigReduction do
    exp = {
      fn(:sin, 0)                  => 0.to_m,
      fn(:sin, :pi/6)              => 1.to_m/2,
      fn(:sin, 17*:pi/6)           => 1.to_m/2,
      fn(:sin, -23*:pi/4)          => - (fn(:sqrt, 2)/2),
      fn(:cos, 0)                  => 1.to_m,
      fn(:cos, 3*:pi/4)            => - (fn(:sqrt, 2)/2),
      fn(:tan, 0)                  => 0.to_m,
      fn(:tan, :pi/4)              => 1.to_m,
      fn(:tan, :pi/2)              => fn(:tan, :pi/2),
      fn(:cot, 0)                  => fn(:cot, 0),
      fn(:cot, -:pi/6)             => fn(:sqrt, 3),
      fn(:sec, 0)                  => 1.to_m,
      fn(:sec, :pi/4)              => fn(:sqrt, 2)/2,
      fn(:csc, 0)                  => 1.to_m,
      fn(:csc, 3*:pi/4)            => - (fn(:sqrt, 2)/2),
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to}'" do
        expect(op(:trigreduct, from).evaluate).to be_equal_to to
      end
    end
  end
end
