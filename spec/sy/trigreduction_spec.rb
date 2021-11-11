require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', trigreduction' do
    exp = {
      sin(0)                 => 0.to_m,
      sin(pi/6)              => 1.to_m/2,
      sin(17*pi/6)           => 1.to_m/2,
      sin(-23*pi/4)          => sqrt(2)/2,
      cos(0)                 => 1.to_m,
      cos(3*pi/4)            => - sqrt(2)/2,
      tan(0)                 => 0.to_m,
      tan(pi/4)              => 1.to_m,
      cot(-pi/6)             => - sqrt(3),
      sec(0)                 => 1.to_m,
      sec(pi/4)              => sqrt(2)/2,
      csc(0)                 => 1.to_m,
      csc(3*pi/4)            => - sqrt(2)/2,
      arcsin(-sqrt(3)/2)     => -pi/3,
      arcsin(1)              => pi/2,
      arccos(sqrt(2)/2)      => pi/4,
      arccos(0)              => pi/2,
      arctan(1)              => pi/4,
      arctan(sqrt(3))        => pi/3,
      arccot(sqrt(3))        => pi/6,
      arccot(sqrt(3)/3)      => pi/3,
      arcsec(1)              => 0,
      arcsec(-2*sqrt(3)/3)   => 5*pi/6,
      arccsc(-2)             => -pi/6,
      arccsc(sqrt(2))        => pi/4,
    }

    exp.each do |from, to|
      it "reduces '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end

    nored = [
      sin(pi/14),
      cos(-pi/5),
      tan(pi/2),
      tan(-3*pi/9),
      cot(0),
      cot(-17*pi/5),
      sec(3*pi/11),
      csc(-3*pi/13),
    ];

    nored.each do |n|
      it "does not reduce '#{n.to_s}'" do
        expect(n.normalize).to be_equal_to n
      end
    end
  end
end
