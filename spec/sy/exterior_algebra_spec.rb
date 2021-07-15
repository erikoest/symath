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

  da = :a.to_m('dform')
  av = :a.to_m('vector')

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
      Sy.set_metric([[1, 0], [0, 1]].to_m, [:x1, :x2].to_m)

      expect { op(:curl, -x2*x1v).evaluate }.to raise_error(RuntimeError,
        'Curl is only defined for 3 dimensions')

      Sy.set_metric([[1, 0, 0], [0, 1, 0], [0, 0, 1]].to_m,
        [:x1, :x2, :x3].to_m)
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

    it 'raises error on other dimensions than 3' do
      Sy.set_metric([[1, 0], [0, 1]].to_m, [:x1, :x2].to_m)

      expect { op(:div, -x2*x1v).evaluate }.to raise_error(RuntimeError,
        'Div is only defined for 3 dimensions')

      Sy.set_metric([[1, 0, 0], [0, 1, 0], [0, 0, 1]].to_m,
        [:x1, :x2, :x3].to_m)
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

  describe Sy::Hodge do
    hodge = {
      op(:hodge, dx1^dx2) => dx3,
      op(:hodge, 3) => ((3*dx1)^dx2^dx3),
      op(:hodge, dx2) => (-(dx1^dx3)),
    }

    hodge.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'hodge error' do
      expect { op(:hodge, da).evaluate }.to raise_error 'No hodge dual for da'
    end
  end

  describe Sy::Sharp do
    sharp = {
      op(:sharp, dx1^dx2) => (x1v^x2v),
      op(:sharp, 3*dx2) => 3*x2v,
    }

    sharp.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'sharp error' do
      expect { op(:sharp, da).evaluate }.to raise_error 'No vector dual for da'
    end
  end

  describe Sy::Flat do
    flat = {
      op(:flat, x1v^x2v) => (dx1^dx2),
      op(:flat, 3*x2v) => 3*dx2,
    }

    flat.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'flat error' do
      expect { op(:flat, av).evaluate }.to raise_error 'No dform dual for a\''
    end
  end
end
