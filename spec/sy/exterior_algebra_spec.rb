require 'spec_helper'
require 'sy'

module Sy
  n = Sy::Operation::Normalization.new

  describe Sy::Grad do
    grad = {
      op(:grad, :x1.to_m - :x1.to_m*:x2 + :x3.to_m**2) => '(1 - x2)*x1\' + 2*x3*x3\' - x1*x2\''
    }

    grad.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end

  describe Sy::Curl do
    curl = {
      op(:curl, -:x2.to_m*:x1.to_m('vector') + :x1.to_m*:x2*:x2.to_m('vector') + :x3.to_m*:x3.to_m('vector')) => '(x2 + 1)*x3\''
    }

    curl.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end

  describe Sy::Div do
    div = {
      op(:div, -:x2.to_m*:x1.to_m('vector') + :x1.to_m*:x2*:x2.to_m('vector') + :x3.to_m*:x3.to_m('vector')) => 'x1 + 1'
    }

    div.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to}'" do
        n.act(from.evaluate).to_s.should == to
      end
    end
  end
end
