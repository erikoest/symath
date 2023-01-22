require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Value, ', to_s' do

    a = :a.to_m
    b = :b.to_m
    da = :da.to_m('form')
    xv = :x.to_m('vector')
    yv = :y.to_m('vector')
    t = :t.to_m(SyMath::Type.new('tensor', indexes: ['u', 'l']))
    m = :m.to_m(SyMath::Type.new('matrix', dimm: 2, dimn: 3))
    mx = [[1, 2, 3], [4, 5, 6]].to_m
    define_op(:o, [:x, :y])

    # Constant symbols
    it 'pi to s' do expect(:pi.to_m.to_s).to be == 'pi' end
    it 'i to s' do expect(:i.to_m.to_s).to be == 'i' end

    # Types
    it '1234 to s' do expect(1234.to_m.to_s).to be == '1234' end
    it 'vector to s' do expect(xv.to_s).to be == 'x\'' end
    it 'form to s' do expect(da.to_s).to be == 'da' end
    it 'tensor to s' do expect(t.to_s).to be == 't[\'.]' end
    it 'simple type to s' do expect(a.type.to_s).to be == 'real' end
    it 'matrix type to s' do expect(m.type.to_s).to be == 'matrix[2x3]' end
    it 'tensor type to s' do expect(t.type.to_s).to be == 'tensor[ul]' end

    # Basic operators
    it 'sum to s' do
      expect((a + b + 1).to_s).to be == 'a + b + 1'
    end
    it 'sum to s' do
      SyMath::setting(:expl_parentheses, true)
      expect((a + b + 1).to_s).to be == '((a + b) + 1)'
      SyMath::setting(:expl_parentheses, false)
    end
    it 'sum with minus to s' do
      expect((a + b - 1).to_s).to be == 'a + b - 1'
    end
    it 'sum with minus to s' do
      SyMath::setting(:expl_parentheses, true)
      expect((a + b - 1).to_s).to be == '((a + b) + (- 1))'
      SyMath::setting(:expl_parentheses, false)
    end
    it 'minus of sum to s' do
      expect(((a + b).neg).to_s).to be == '- (a + b)'
    end
    it 'product to s' do
      expect((2 * a * b).to_s).to be == '2*a*b'
    end
    it 'product to s' do
      SyMath::setting(:expl_parentheses, true)
      expect((2 * a * b).to_s).to be == '((2*a)*b)'
      SyMath::setting(:expl_parentheses, false)
    end
    it 'product of sums to s' do
      expect((2 * (a + b)).to_s).to be == '2*(a + b)'
    end
    it 'fraction to s' do
      expect((a/b).to_s).to be == 'a/b'
    end
    it 'fraction to s' do
      SyMath::setting(:expl_parentheses, true)
      expect((a/b).to_s).to be == '(a/b)'
      SyMath::setting(:expl_parentheses, false)
    end
    it 'fraction of sums to s' do
      expect(((a + 2)/(b + 2)).to_s).to be == '(a + 2)/(b + 2)'
    end
    it 'power to s' do
      expect((a**b).to_s).to be == 'a**b'
    end
    it 'power of sum to s' do
      expect(((a + 2)**(b + 2)).to_s).to be == '(a + 2)**(b + 2)'
    end

    # Integral
    it 'unbound integral to s' do
      expect(int(a).to_s).to be == 'int(a)'
    end
    it 'unbound integral with variable to s' do
      expect(int(a).to_s).to be == 'int(a)'
    end
    it 'bound integral to s' do
      expect(int(a, 1.to_m, 10.to_m).to_s).to be ==
        'int(a,1,10)'
    end
    it 'bounds operator to s' do
      expect(bounds(a, b, 1, 2).to_s).to be ==
        '[a](1,2)'
    end
    
    # Common functions
    it 'factorial to s' do
      expect(fact(:a).to_s).to be == 'a!'
    end
    it 'abs to s' do
      expect(abs(:a).to_s).to be == '|a|'
    end
    
    # Named operator
    it 'op to s' do
      expect(op(:o, :a, :b).to_s).to be == 'o(a,b)'
    end
    
    # Exterior algebra
    it 'wedge to s' do
      expect((xv^yv).to_s).to be == 'x\'^y\''
    end
    it 'wedge to s' do
      SyMath::setting(:expl_parentheses, true)
      expect((xv^yv).to_s).to be == '(x\'^y\')'
      SyMath::setting(:expl_parentheses, false)
    end
    it 'flat to string' do
      expect(flat(:a).to_s).to be == 'b(a)'
    end
    it 'sharp to string' do
      expect(sharp(:a).to_s).to be == '#(a)'
    end

    # Matrix
    it 'matrix to string' do
      expect(mx.to_s).to be == '[1, 2, 3; 4, 5, 6]'
    end
  end
end
