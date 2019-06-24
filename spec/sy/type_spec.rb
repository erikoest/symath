require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Type do
    it "real and integer has real as common parent" do
      int = 'integer'.to_t
      real = 'real'.to_t
      int.common_parent(real).name.should == 'real'
    end

    it "rational and imaginary has complex as common parent" do
      rat = 'rational'.to_t
      im = 'imaginary'.to_t
      rat.common_parent(im).name.should == 'complex'
    end
  end
end
