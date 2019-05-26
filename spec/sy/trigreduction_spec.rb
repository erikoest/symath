require 'spec_helper'
require 'sy'

module Sy
  describe Sy::TrigReduction do
    exp = {
      fn(:sin, 0)                       => '0',
      fn(:sin, :pi.to_m/6)              => '1/2',
      fn(:sin, 17.to_m*:pi/6)           => '1/2',
      fn(:sin, -23.to_m*:pi/4)          => '- sqrt(2)/2',
      fn(:cos, 0)                       => '1',
      fn(:cos, 3.to_m*:pi/4)            => '- sqrt(2)/2',
      fn(:tan, 0)                       => '0',
      fn(:tan, :pi.to_m/4)              => '1',
      fn(:tan, :pi.to_m/2)              => 'tan(pi/2)',
      fn(:cot, 0)                       => 'cot(0)',
      fn(:cot, -:pi.to_m/6)             => 'sqrt(3)',
      fn(:sec, 0)                       => '1',
      fn(:sec, :pi.to_m/4)              => 'sqrt(2)/2',
      fn(:csc, 0)                       => '1',
      fn(:csc, 3.to_m*:pi/4)            => '- sqrt(2)/2',
    }

    exp.each do |from, to|
      it "multiplies '#{from.to_s}' to '#{to}'" do
        op(:trigreduct, from).act.to_s.should == to
      end
    end
  end
end
