require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Definition::Constant, ', quaternion algebra' do
    expressions = {
      i*j => k,
      j*k => i,
      k*i => j,
      j*i => -k,
      k*j => -i,
      i*k => -j,
      i*j*k => -1,
      j*i*k => 1,
      i**2 => -1,
      j**2 => -1,
      k**2 => -1,
      i**4 => 1,
      j**4 => 1,
      k**4 => 1,
    }

    expressions.each do |from, to|
      it "normalizes '#{from.to_s}' to '#{to.to_s}'" do
        expect(from.normalize).to be_equal_to to
      end
    end
  end
end
