require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Matrix do
    m23 = [[1, 2, 3], [4, 5, 6]].to_m
    m32 = [[-1, 3], [-4, -5], [2, 1]].to_m

    s1 = [[1, 2], [-1, -2]].to_m
    s2 = [[3, 4], [-4, 4]].to_m
    s3 = [[4, 5], [5, 6]].to_m
    s4 = [[-2, -1, 2], [2, 1, 4], [-3, 3, -1]].to_m

    i = [[1, 0], [0, 1]].to_m
    rx = [[0, 1], [1, 0]].to_m
    ry = [[0, -:i], [:i, 0]].to_m
    rz = [[1, 0], [0, -1]].to_m

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

    it 'matrix divided by scalar' do
      expect((s2/2).evaluate.normalize.to_s).to be == '[3/2, 2; - 2, 2]'
    end

    it 'trace of matrices' do
      expect(s1.trace).to be_equal_to -1
      expect(s2.trace).to be_equal_to 7
    end

    it 'matrix determinant' do
      expect(s2.determinant.normalize).to be_equal_to 28
      expect(s3.determinant.normalize).to be_equal_to -1
      expect((s2*s3).evaluate.determinant.normalize).to be_equal_to -28
      expect(s4.determinant.normalize).to be_equal_to 54
      expect(s4.transpose.determinant.normalize).to be_equal_to 54
    end

    it 'matrix inverse' do
      expect(s2.inverse.normalize.to_s).to be == '[1/7, (- 1)/7; 1/7, 3/28]'
      expect((s2.inverse*s2).evaluate.normalize.to_s).to be ==
        '[1, 0; 0, 1]'
      expect((s3.inverse*s3).evaluate.normalize.to_s).to be ==
        '[1, 0; 0, 1]'
    end

    it 'tests with spin matrices' do
      expect((rx*rx).evaluate.normalize).to be_equal_to i
      expect((ry*ry).evaluate.normalize).to be_equal_to i
      expect((rz*rz).evaluate.normalize).to be_equal_to i

      expect((-:i*rx*ry*rz).evaluate_recursive.normalize).to be_equal_to i

      expect(rx.trace).to be_equal_to 0
      expect(ry.trace).to be_equal_to 0
      expect(rz.trace).to be_equal_to 0

      expect(rx.determinant.normalize).to be_equal_to -1
      expect(ry.determinant.normalize).to be_equal_to -1
      expect(rz.determinant.normalize).to be_equal_to -1
    end

    it 'trace of non-square matrix raises error' do
      expect { m23.trace }.to raise_error 'Matrix is not square'
    end
  end
end
