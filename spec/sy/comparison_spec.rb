require 'spec_helper'
require 'sy'
require 'set'

module Sy
  describe Sy::Value, ', equality' do
    it ":x == 'x'" do
      expect(:x.to_m).to be == 'x'.to_m
    end

    it "10 == 10" do
      expect(10.to_m).to be == 10.to_m
    end
  end

  describe Sy::Value, ', comparison' do
    it '900 < :x' do
      expect(900.to_m).to be < :x.to_m
    end

    it 'sin(:x) > :x' do
      expect(fn(:sin, :x)).to be > :x.to_m
    end

    it 'cos(:x) < sin(:x)' do
      expect(fn(:cos, :x)).to be < fn(:sin, :x)
    end

    it 'cos(:x) <= cos(:x)' do
      expect(fn(:cos, :x)).to be <= fn(:cos, :x)
    end

    it ":x <= 'x'" do
      expect(:x.to_m).to be <= 'x'.to_m
    end

    it ":x >= 'x'" do
      expect(:x.to_m).to be >= 'x'.to_m
    end

    it 'cos(:x) < cos(:y)' do
      expect(fn(:cos, :x)).to be < fn(:cos, :y)
    end
  end

  describe Sy::Value, ', sorting' do
    it '[sin(:x), 100, :x, :y*:z] sorts to [sin(:x), :y*:z, :x, 100]' do
      expect([fn(:sin, :x), 100.to_m, :x.to_m, :y.to_m*:z, ].sort).to be ==
        [100.to_m, :x.to_m, :y.to_m*:z, fn(:sin, :x)]
    end
  end

  describe Sy::Value, ', hashing' do
    it ":x and 'x' hashes into the same keys" do
      h = { :x.to_m => 1 }
      expect(h.key?('x'.to_m)).to be == true
    end
  end

  describe Sy::Value, ', set operations' do
    it ":x == 'x' as set elements" do
      s = [ :x.to_m ].to_set
      expect(s.member?('x'.to_m)).to be == true
    end
  end
end
