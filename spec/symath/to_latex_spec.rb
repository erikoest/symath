require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Value, ', to_latex' do

    a = :a.to_m
    b = :b.to_m
    da = d(:a)
    xv = :x.to_m('vector')
    yv = :y.to_m('vector')
    t = :t.to_m(SyMath::Type.new('tensor', indexes: ['u', 'l']))
    define_fn(:fltx, [:x, :y])
    define_op(:oltx, [:x, :y])

    # Constant symbols
    it 'pi to latex' do expect(pi.to_latex).to be == '\pi' end
    it 'e to latex' do expect(e.to_latex).to be == '\mathrm{e}' end
    it 'i to latex' do expect(i.to_latex).to be == 'i' end
    it 'phi to latex' do expect(phi.to_latex).to be == '\varphi' end
    it 'NaN to latex' do expect(:nan.to_m.to_latex).to be == '\mathrm{NaN}' end
    it 'oo to latex' do expect(oo.to_latex).to be == '\infty' end
    it 'x to latex' do expect(:x.to_m.to_latex).to be == 'x' end

    # Types
    it '1234 to latex' do expect(1234.to_m.to_latex).to be == '1234' end
    it 'vector to latex' do expect(xv.to_latex).to be == '\vec{x}' end
    it 'form to latex' do expect(da.to_latex).to be == 'da' end
    it 'tensor to latex' do expect(t.to_latex).to be == 't[\'.]' end

    # Basic operators
    it 'sum to latex' do
      expect((a + b + 1).to_latex).to be == 'a + b + 1'
    end
    it 'sum with minus to latex' do
      expect((a + b - 1).to_latex).to be == 'a + b - 1'
    end
    it 'product to latex' do
      expect((2 * a * b).to_latex).to be == '2 a b'
    end
    it 'product of sums to latex' do
      expect((2 * (a + b)).to_latex).to be == '2 (a + b)'
    end
    it 'product with explicit point to latex' do
      SyMath.setting(:ltx_product_sign, true)
      expect((2 * a).to_latex).to be == '2 \cdot a'
      SyMath.setting(:ltx_product_sign, false)
    end
    it 'fraction to latex' do
      expect((a/b).to_latex).to be == '\frac{a}{b}'
    end
    it 'power to latex' do
      expect((a**b).to_latex).to be == 'a^{b}'
    end
    it 'power of sum to latex' do
      expect(((a + b)**2).to_latex).to be == '\left(a + b\right)^{2}'
    end

    # Equation
    it 'equation to latex' do
      expect('x = 2'.to_m.to_latex).to be == 'x = 2'
    end

    # Differential, integral
    it 'differental to latex' do
      expect(d(2*a).to_latex).to be == '\mathrm{d}(2 a)'
    end
    it 'differental to latex' do
      expect(xd(a).to_latex).to be == '\mathrm{d}(a)'
    end
    it 'unbound integral to latex' do
      expect(int(a).to_latex).to be == '\int a\,da'
    end
    it 'unbound integral of sum to latex' do
      expect(int(a + b).to_latex).to be ==
        '\int \\left(a + b\\right)\,da'
    end
    it 'bound integral to latex' do
      expect(int(a, 1.to_m, 10.to_m).to_latex).to be ==
        '\int_{1}^{10} a\,da'
    end
    it 'bounds operator to latex' do
      expect(bounds(a, b, 1, 2).to_latex).to be ==
        '\left[a\right]^{2}_{1}'
    end

    # Common functions
    it 'factorial to latex' do
      expect(fact(:a).to_latex).to be == 'a!'
    end
    it 'sqrt to latex' do
      expect(sqrt(:a).to_latex).to be == '\sqrt{a}'
    end
    it 'abs to latex' do
      expect(abs(:a).to_latex).to be == '\lverta\rvert'
    end

    # function
    it 'fn to latex' do
      expect(fn(:fltx, :a, :b).to_latex).to be == 'fltx(a,b)'
    end
    # operator
    it 'op to latex' do
      expect(op(:oltx, :a, :b).to_latex).to be == '\operatorname{oltx}(a,b)'
    end

    # Exterior algebra
    it 'wedge to latex' do
      expect((xv^yv).to_latex).to be == '\vec{x}\wedge\vec{y}'
    end
    it 'flat to latex' do
      expect(flat(:a).to_latex).to be == 'a^\flat'
    end
    it 'sharp to latex' do
      expect(sharp(:a).to_latex).to be == 'a^\sharp'
    end
    it 'hodge to latex' do
      expect(hodge(:a).to_latex).to be == '\star a'
    end
    it 'curl to latex' do
      expect(curl(:a).to_latex).to be == '\nabla\times a'
    end
    it 'div to latex' do
      expect(div(:a).to_latex).to be == '\nabla\cdot a'
    end
    it 'laplacian to latex' do
      expect(laplacian(:a).to_latex).to be == '\nabla^2 a'
    end
    it 'codiff to latex' do
      expect(codiff(:a).to_latex).to be == '\delta a'
    end
    it 'grad to latex' do
      expect(grad(:a).to_latex).to be == '\nabla a'
    end
  end
end
