require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Type do
    it "real and integer has real as common parent" do
      int = 'integer'.to_t
      real = 'real'.to_t
      expect(int.common_parent(real).name).to be == :real
    end

    it "rational and imaginary has complex as common parent" do
      rat = 'rational'.to_t
      im = 'imaginary'.to_t
      expect(rat.common_parent(im).name).to be == :complex
    end
  end
end
