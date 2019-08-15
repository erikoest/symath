require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::TrigReduction do
    exp = {
      fn(:sin, 0)                  => '0',
      fn(:sin, :pi/6)              => '1/2',
      fn(:sin, 17*:pi/6)           => '1/2',
      fn(:sin, -23*:pi/4)          => '- sqrt(2)/2',
      fn(:cos, 0)                  => '1',
      fn(:cos, 3*:pi/4)            => '- sqrt(2)/2',
      fn(:tan, 0)                  => '0',
      fn(:tan, :pi/4)              => '1',
      fn(:tan, :pi/2)              => 'tan(pi/2)',
      fn(:cot, 0)                  => 'cot(0)',
      fn(:cot, -:pi/6)             => 'sqrt(3)',
      fn(:sec, 0)                  => '1',
      fn(:sec, :pi/4)              => 'sqrt(2)/2',
      fn(:csc, 0)                  => '1',
      fn(:csc, 3*:pi/4)            => '- sqrt(2)/2',
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to}'" do
        expect(op(:trigreduct, from).evaluate.to_s).to be == to
      end
    end
  end
end
