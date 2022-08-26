require 'spec_helper'
require 'symath'

module SyMath
  x1 = :x1
  x2 = :x2
  x3 = :x3
  x1v = :x1.to_m('vector')
  x2v = :x2.to_m('vector')
  x3v = :x3.to_m('vector')

  dx1 = :dx1.to_m('dform')
  dx2 = :dx2.to_m('dform')
  dx3 = :dx3.to_m('dform')

  da = :da.to_m('dform')
  av = :a.to_m('vector')

  describe SyMath::Definition::Grad do
    g = {
      grad(x1 - x1*x2 + x3**2) => x1v + 2*x3*x3v - x2*x1v - x1*x2v
    }

    g.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe SyMath::Definition::Curl do
    c = {
      curl(-x2*x1v + x1*x2*x2v + x3*x3v) => x3v + x2*x3v
    }

    c.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'raises error on other dimensions than 3' do
      SyMath.set_default_vector_space('minkowski_4d')

      expect { curl(-x2*x1v).evaluate }.to raise_error(RuntimeError,
        'Curl is only defined for 3 dimensions')

      SyMath.set_default_vector_space('euclidean_3d')
    end
  end

  describe SyMath::Definition::Div do
    d = {
      div(-x2*x1v + x1*x2*x2v + x3*x3v) => x1 + 1
    }

    d.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'raises error on other dimensions than 3' do
      SyMath.set_default_vector_space('minkowski_4d')

      expect { div(-x2*x1v).evaluate }.to raise_error(RuntimeError,
        'Div is only defined for 3 dimensions')

      SyMath.set_default_vector_space('euclidean_3d')
    end
  end

  describe SyMath::Definition::Laplacian do
    lap = {
      laplacian(x1**2 + x2**2 + x3**2) => 6.to_m
    }
    
    lap.each do |from, to|
      it "evaluates '#{from.to_s}' into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe SyMath::Definition::CoDiff do
    cd = {
      codiff(x1**2*(dx1^dx3) + x2**2*(dx3^dx1) + x3**2*(dx1^dx2)) => 2*x1*dx3
    }

    cd.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end
  end

  describe SyMath::Definition::Hodge do
    hdg = {
      hodge(dx1^dx2) => dx3,
      hodge(3) => ((3*dx1)^dx2^dx3),
      hodge(dx2) => (-(dx1^dx3)),
    }

    hdg.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'hodge error' do
      expect { hodge(da).evaluate }.to raise_error 'No hodge dual for da'
    end
  end

  describe SyMath::Definition::Sharp do
    sh = {
      sharp(dx1^dx2) => (x1v^x2v),
      sharp(3*dx2) => 3*x2v,
    }

    sh.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'sharp error' do
      expect { sharp(da).evaluate }.to raise_error 'No vector dual for da'
    end
  end

  describe SyMath::Definition::Flat do
    fl = {
      flat(x1v^x2v) => (dx1^dx2),
      flat(3*x2v) => 3*dx2,
    }

    fl.each do |from, to|
      it "evaluates '#{from.to_s} into '#{to.to_s}'" do
        expect(from.evaluate.normalize).to be_equal_to to
      end
    end

    it 'flat error' do
      expect { op(:flat, av).evaluate }.to raise_error 'No dform dual for a\''
    end
  end
end
