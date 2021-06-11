require 'spec_helper'
require 'sy'

module Sy
  x1 = :x1
  x2 = :x2
  x3 = :x3
  x1v = :x1.to_m('vector')
  x2v = :x2.to_m('vector')
  x3v = :x3.to_m('vector')

  dx1 = :x1.to_m('dform')
  dx2 = :x2.to_m('dform')
  dx3 = :x3.to_m('dform')
  
  describe Sy::Grad do
    grad = {
      op(:grad, x1 - x1*x2 + x3**2) => x1v + 2*x3*x3v - x2*x1v - x1*x2v
    }

    grad.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Curl do
    curl = {
      op(:curl, -x2*x1v + x1*x2*x2v + x3*x3v) => x3v + x2*x3v
    }

    curl.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'raises error on other dimensions than 3' do
      # Note: Changing basis dim raises an error because metric tensor
      # is no longer compatible with the basis. Must find a solution to
      # this.
      begin
        Sy.assign_variable(:basis.to_m, [:x1, :x2].to_m)
      rescue
      end
      Sy.assign_variable(:g.to_m, [[1, 0], [0, 1]].to_m)

      expect { op(:curl, -x2*x1v).evaluate }.to raise_error(RuntimeError,
        'Curl is only defined for 3 dimensions')

      expect { op(:div, -x2*x1v).evaluate }.to raise_error(RuntimeError,
        'Div is only defined for 3 dimensions')

      begin
        Sy.assign_variable(:basis.to_m, [:x1, :x2, :x3].to_m)
      rescue
      end
      Sy.assign_variable(:g.to_m, [[1, 0, 0], [0, 1, 0], [0, 0, 1]].to_m)
    end
  end

  describe Sy::Div do
    div = {
      op(:div, -x2*x1v + x1*x2*x2v + x3*x3v) => x1 + 1
    }

    div.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::Laplacian do
    div = {
      op(:laplacian, x1**2 + x2**2 + x3**2) => 6.to_m
    }
    
    div.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe Sy::CoDiff do
    codiff = {
      op(:codiff, x1**2*(dx1^dx3) + x2**2*(dx3^dx1) + x3**2*(dx1^dx2)) => 2*x1*dx3
    }

    codiff.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end
end
