require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Normalization.new

  describe Sy::Normalization, ', normalize sum' do
    sums = {
      1.to_m + 3                  => '4',
      3.to_m/4 + (5.to_m + 2)/34  => '7/34 + 3/4',
      :x.to_m + :x                => '2*x',
      :x.to_m - :x                => '0',
      fn(:sin, :x) + fn(:sin, :x)*2 + 3.to_m*:y - 3.to_m*:y => '3*sin(x)',
    }

    sums.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        n.act(from).to_s.should == to
      end
    end
  end

  describe Sy::Normalization, ', normalize product' do
    products = {
      :x.to_m * :x              => 'x^2',
      :x.to_m * (-:x.to_m)      => '- x^2',
      :x.to_m * :x.to_m ** 2    => 'x^3',
      :x.to_m * 4 * :x * 3 * :y * :y.to_m ** 10 => '12*x^2*y^11',
      :x.to_m / :y.to_m * :a / :b.to_m          => 'a*x/(b*y)',
      14175.to_m / 9000.to_m    => '63/40',
      fn(:cos, :x)*:y           => 'y*cos(x)',
    }

    products.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        n.act(from).to_s.should == to
      end
    end
  end

  describe Sy::Normalization, ', normalize power' do
    powers = {
      (:x.to_m**2)**3           => 'x^6',
      (:x.to_m**2)**(:y.to_m)   => 'x^(2*y)',
    }

    powers.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to}'" do
        n.act(from).to_s.should == to
      end
    end
  end
end
