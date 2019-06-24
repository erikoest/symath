require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Operation::Normalization, ', normalize sum' do
    sums = {
      1.to_m + 3                  => '4',
      3.to_m/4 + (5.to_m + 2)/34  => '7/34 + 3/4',
      :x.to_m + :x                => '2*x',
      :x.to_m - :x                => '0',
      fn(:sin, :x) + fn(:sin, :x)*2 + 3.to_m*:y - 3.to_m*:y => '3*sin(x)',
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
      fn(:cos, :x)*:y           => 'y*cos(x)',
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
    
    wedges = {
      dx^dx                           => '0',
      dy^dx^dz                        => '- dx^dy^dz',
      fn(:sin, :x.to_m)*dy^dx         => '- sin(x)*dx^dy',
      :x.to_m**3^dy*:e.to_m**4^dz^dx  => 'e**4*x**3*dx^dy^dz',
      dx + (:x.to_m**1.to_m^dx)       => 'dx + x*dx',
    }

    wedges.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        op(:norm, from).evaluate.to_s.should == to
      end
    end
  end
end
