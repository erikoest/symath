require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Matrix do
    m23 = [[1, 2, 3], [4, 5, 6]].to_m
    m32 = [[-1, 3], [-4, -5], [2, 1]].to_m

    s1 = [[1, 2], [-1, -2]].to_m
    s2 = [[3, 4], [-4, 4]].to_m
    
    it 'product of matrices' do
      expect((m23*m32).evaluate.normalize.to_s).to be == '[- 3, - 4; - 12, - 7]'
    end

    it 'product of scalar and matrix' do
      expect((m23*2).evaluate.normalize.to_s).to be == '[2, 4, 6; 8, 10, 12]'
      expect((2*m23).evaluate.normalize.to_s).to be == '[2, 4, 6; 8, 10, 12]'
    end

    it 'sum of matrices' do
      expect((s1 + s2).evaluate.normalize.to_s).to be == '[4, 6; - 5, 2]'
    end

    it 'subtraction of matrices' do
      expect((s1 - s2).evaluate.normalize.to_s).to be == '[- 2, - 2; 3, - 6]'
    end

    it 'trace of matrices' do
      expect(s1.trace).to be_equal_to -1
      expect(s2.trace).to be_equal_to 7
    end

    it 'trace of non-square matrix raises error' do
      expect { m23.trace }.to raise_error 'Matrix is not square'
    end
  end
end
