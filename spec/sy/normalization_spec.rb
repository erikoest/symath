require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', normalize sum' do
    sums = {
      1.to_m + 3                   => '4',
      3.to_m/4 + (5.to_m + 2)/34   => '7/34 + 3/4',
      :x.to_m + :x                 => '2*x',
      :x.to_m - :x                 => '0',
      fn(:sin, :x) + fn(:sin, :x)*2 + 3.to_m*:y - 3.to_m*:y => '3*sin(x)',
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
      :x.to_m * :x              => 'x**2',
      :x.to_m * (-:x.to_m)      => '- x**2',
      :x.to_m * :x.to_m ** 2    => 'x**3',
      :x.to_m * 4 * :x * 3 * :y * :y.to_m ** 10 => '12*x**2*y**11',
      :x.to_m / :y.to_m * :a / :b.to_m          => 'a*x/(b*y)',
      14175.to_m / 9000.to_m    => '63/40',
      fn(:cos, :x)*:y           => 'cos(x)*y',
    }

    products.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end

  describe Sy::Operation::Normalization, ', normalize power' do
    powers = {
      (:x.to_m**2)**3           => 'x**6',
      (:x.to_m**2)**(:y.to_m)   => 'x**(2*y)',
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

    x = :x.to_m
    a = :a.to_m
    
    wedges = {
      dx^dx                           => '0',
      dy^dx^dz                        => '- dx^dy^dz',
      fn(:sin, x)*dy^dx               => '- sin(x)*dx^dy',
      :x.to_m**3^dy*:e.to_m**4^dz^dx  => 'x**3*e**4*dx^dy^dz',
      dx + (x**1.to_m^dx)             => '(x + 1)*dx',
      (dx^fn(:ln, a*x)) + ((x^1.to_m)/(a*x)^((0.to_m^x) + (a^dx))) - dx => 'ln(a*x)*dx'
    }

    wedges.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end
end
