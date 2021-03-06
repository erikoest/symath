require 'spec_helper'
require 'symath'
require 'set'

module SyMath
  describe SyMath::Value, ', equality' do
    it ":x == 'x'" do
      expect(:x.to_m).to be == 'x'.to_m
    end

    it "10 == 10" do
      expect(10.to_m).to be == 10.to_m
    end
  end

  describe SyMath::Value, ', comparison' do
    it '900 < :x' do
      puts self.class.superclass.to_s
      expect(900.to_m).to be < :x.to_m
    end

    it 'sin(:x) > :x' do
      expect(sin(:x)).to be > :x.to_m
    end

    it 'cos(:x) < sin(:x)' do
      expect(cos(:x)).to be < sin(:x)
    end

    it 'cos(:x) <= cos(:x)' do
      expect(cos(:x)).to be <= cos(:x)
    end

    it ":x <= 'x'" do
      expect(:x.to_m).to be <= 'x'.to_m
    end

    it ":x >= 'x'" do
      expect(:x.to_m).to be >= 'x'.to_m
    end

    it 'cos(:x) < cos(:y)' do
      expect(cos(:x)).to be < cos(:y)
    end
  end

  describe SyMath::Value, ', sorting' do
    it '[sin(:x), 100, :x, :y*:z] sorts to [sin(:x), :y*:z, :x, 100]' do
      expect([sin(:x), 100.to_m, :x.to_m, :y.to_m*:z, ].sort).to be ==
        [100.to_m, :x.to_m, :y.to_m*:z, sin(:x)]
    end
  end

  describe SyMath::Value, ', hashing' do
    it ":x and 'x' hashes into the same keys" do
      h = { :x.to_m => 1 }
      expect(h.key?('x'.to_m)).to be == true
    end
  end

  describe SyMath::Value, ', set operations' do
    it ":x == 'x' as set elements" do
      s = [ :x.to_m ].to_set
      expect(s.member?('x'.to_m)).to be == true
    end
  end
end
