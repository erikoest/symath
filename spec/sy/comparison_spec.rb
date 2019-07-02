require 'spec_helper'
require 'sy'
require 'set'

module Sy
  describe Sy::Value, ', equality' do
    it "equals :x with 'x'" do
      :x.to_m.should == 'x'.to_m
    end

    it "equals 10 with 10" do
      10.to_m.should == 10.to_m
    end
  end

  describe Sy::Value, ', comparison' do
    it 'compares 900 > :x' do
      900.to_m.should > :x.to_m
    end

    it 'compares sin(:x) < :x' do
      fn(:sin, :x).should < :x.to_m
    end

    it 'compares cos(:x) < sin(:x)' do
      fn(:cos, :x).should < fn(:sin, :x)
    end

    it 'compares cos(:x) <= cos(:x)' do
      fn(:cos, :x).should <= fn(:cos, :x)
    end

    it "compares :x <= 'x'" do
      :x.to_m.should <= 'x'.to_m
    end

    it "compares :x >= 'x'" do
      :x.to_m.should >= 'x'.to_m
    end

    it 'compares cos(:x) < cos(:y)' do
      fn(:cos, :x).should < fn(:cos, :y)
    end
  end

  describe Sy::Value, ', sorting' do
    it 'sorts [sin(:x), 100, :x, :y*:z] into [sin(:x), :y*:z, :x, 100]' do
      [fn(:sin, :x), 100.to_m, :x.to_m, :y.to_m*:z].sort.should ==
        [fn(:sin, :x), :y.to_m*:z, :x.to_m, 100.to_m]
    end
  end

  describe Sy::Value, ', hashing' do
    it "hashes :x and 'x' into the same keys" do
      h = { :x.to_m => 1 }
      h.key?('x'.to_m).should == true
    end
  end

  describe Sy::Value, ', set operations' do
    it "equals :x and 'x' as set elements" do
      s = [ :x.to_m ].to_set
      s.member?('x'.to_m).should == true
    end
  end
end
