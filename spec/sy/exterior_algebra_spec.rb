require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  x1 = :x1
  x2 = :x2
  x3 = :x3
  x1v = :x1.to_m('vector')
  x2v = :x2.to_m('vector')
  x3v = :x3.to_m('vector')
  
  describe Sy::Grad do
    grad = {
      op(:grad, x1 - x1*x2 + x3**2) => (1 - x2)*x1v - x1*x2v + 2*x3*x3v
    }

    grad.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        expect(n.act(from.evaluate)).to be == to
      end
    end
  end

  describe Sy::Curl do
    curl = {
      op(:curl, -x2*x1v + x1*x2*x2v + x3*x3v) => (x2 + 1)*x3v
    }

    curl.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        expect(n.act(from.evaluate)).to be == to
      end
    end
  end

  describe Sy::Div do
    div = {
      op(:div, -x2*x1v + x1*x2*x2v + x3*x3v) => x1 + 1
    }

    div.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        expect(n.act(from.evaluate)).to be == to
      end
    end
  end

  describe Sy::Laplacian do
    div = {
      op(:laplacian, x1**2 + x2**2 + x3**2) => 6.to_m
    }
    
    div.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        expect(n.act(from.evaluate)).to be == to
      end
    end
  end
end
