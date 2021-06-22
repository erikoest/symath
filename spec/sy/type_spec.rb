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

    it 'wedge product of mixed vector and dform' do
      w = :a.to_m('vector').wedge(:b.to_m('dform'))
      expect(w.type).to be == 'tensor'.to_t(indexes: ['u', 'l'])
    end

    it 'wedge product of mixed scalar and vector' do
      w = :a.to_m('vector').wedge(:b.to_m)
      expect(w.type).to be == 'vector'.to_t
    end

    it 'wedge product of mixed scalar and dform' do
      w = :a.to_m('dform').wedge(:b.to_m)
      expect(w.type).to be == 'dform'.to_t
    end
  end
end
