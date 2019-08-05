require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', normalize sum' do
    sums = {
      1 + 3                        => '4',
      3.to_m/4 + (5.to_m + 2)/34   => '7/34 + 3/4',
      :x + :x                      => '2*x',
      :x - :x                      => '0',
      fn(:sin, :x) + fn(:sin, :x)*2 + 3*:y - 3*:y => '3*sin(x)',
      2.to_m**3 + 3.to_m**2        => '17',
      3.to_m**-4.to_m + 2.to_m**-5 => '1/32 + 1/81',
    }

    sums.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize product' do
    products = {
      :x * :x                         => 'x**2',
      :x * (-:x)                      => '- x**2',
      :x * :x ** 2                    => 'x**3',
      :x * 4 * :x * 3 * :y * :y ** 10 => '12*x**2*y**11',
      :x / :y * :a / :b               => 'a*x/(b*y)',
      14175.to_m / 9000.to_m          => '63/40',
      fn(:cos, :x)*:y                 => 'cos(x)*y',
    }

    products.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize power' do
    powers = {
      (:x**2)**3      => 'x**6',
      (:x**2)**(:y)   => 'x**(2*y)',
    }

    powers.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize wedge products' do
    dx = :x.to_m('dform')
    dy = :y.to_m('dform')
    dz = :z.to_m('dform')

    wedges = {
      dx^dx                            => '0',
      dy^dx^dz                         => '- dx^dy^dz',
      fn(:sin, :x)*dy^dx               => '- sin(x)*dx^dy',
      :x**3^dy*:e**4^dz^dx             => 'x**3*e**4*dx^dy^dz',
      dx + (:x**1^dx)                  => '(x + 1)*dx',
      (dx^fn(:ln, :a*:x)) + ((:x^1)/(:a*:x)^((0^:x) + (:a^dx))) - dx => 'ln(a*x)*dx'
    }

    wedges.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end
end
