require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Value, ', adding non-finite values (complex)' do
    x = :x.to_m

    # Undetermined
    it 'oo + x == oo + x' do expect(oo + x).to be == oo.add(x) end
    it 'x + oo == x + oo' do expect(x + oo).to be == x.add(oo) end
    it 'oo - x == oo - x' do expect(oo - x).to be == oo.sub(x) end
    it 'x - oo == x - oo' do expect(x - oo).to be == x.sub(oo) end

    # NaN
    it 'oo + oo == NaN'   do expect(oo + oo).to be == nan end
    it 'oo - oo == NaN'   do expect(oo - oo).to be == nan end
    it 'NaN - NaN == NaN' do expect(nan - nan).to be == nan end

    # Infinite sum
    it 'oo + 1 == oo'     do expect(oo + 1).to be == oo end
    it '1 + oo == oo'     do expect(1 + oo).to be == oo end
    it '-oo + 1 == oo'    do expect(-oo + 1).to be == oo end
    it '1 - oo == oo'     do expect(1 - oo).to be == oo end
  end
  
  describe SyMath::Value, ', adding non-finite values (real)' do
    before do
      SyMath.setting(:complex_arithmetic, false)
    end

    x = :x.to_m

    # Undetermined
    it 'oo + x == oo + x' do expect(oo + x).to be == oo.add(x) end
    it 'x + oo == x + oo' do expect(x + oo).to be == x.add(oo) end
    it 'oo - x == oo - x' do expect(oo - x).to be == oo.sub(x) end
    it 'x - oo == x - oo' do expect(x - oo).to be == x.sub(oo) end
    
    # NaN
    it 'NaN + 1 == NaN'  do expect(nan + 1).to be == nan end
    it 'NaN + oo == NaN' do expect(nan + oo).to be == nan end
    it 'NaN - oo == NaN' do expect(nan - oo).to be == nan end
    it '1 + NaN == NaN'  do expect(1 + nan).to be == nan end
    it 'oo + NaN == NaN' do expect(oo + nan).to be == nan end
    it 'oo - NaN == NaN' do expect(oo - nan).to be == nan end
    it 'oo - oo == NaN'  do expect(oo - oo).to be == nan end
    it '-oo + oo == NaN' do expect(-oo + oo).to be == nan end

    # Plus
    it 'oo + 1 == oo'  do expect(oo + 1).to be == oo end
    it '1 + oo == oo'  do expect(1 + oo).to be == oo end
    it 'oo + oo == oo' do expect(oo + oo).to be == oo end

    # Minus
    it '1 - oo == -oo'   do expect(1 - oo).to be == -oo end
    it '-oo + 1 == -oo'  do expect(-oo + 1).to be == -oo end
    it '-oo - oo == -oo' do expect(-oo - oo).to be == -oo end
    it 'NaN is not negative' do expect(nan.is_negative?).to be == false end

    # Power
    it '0**0 == NaN' do expect(0.to_m**0).to be == nan end

    after do
      SyMath.setting(:complex_arithmetic, true)
    end
  end

  describe SyMath::Value, ', multiplying non-finite values (complex)' do
    x = :x.to_m

    # Undetermined
    it 'oo*x == oo*x' do expect(oo*x).to be == oo.mul(x) end
    it 'x*oo == x*oo' do expect(x*oo).to be == x.mul(oo) end
    
    # NaN
    it 'NaN*10 == NaN'  do expect(nan*10).to be == nan end
    it 'NaN*oo == NaN'  do expect(nan*oo).to be == nan end
    it '10*NaN == NaN'  do expect(10*nan).to be == nan end
    it 'oo*NaN == NaN'  do expect(oo*nan).to be == nan end
    it 'oo*0 == NaN'    do expect(oo*0).to be == nan end
    it '0*oo == NaN'    do expect(0*oo).to be == nan end
    
    # Same sign
    it 'oo*oo == oo'    do expect(oo*oo).to be == oo end
    it '-oo*-oo = oo'   do expect(-oo*-oo).to be == oo end

    # Oposite sign
    it 'oo*-oo = oo'   do expect(oo*(-oo)).to be == oo end
    it '-oo*oo = oo'   do expect((-oo)*oo).to be == oo end
  end

  describe SyMath::Value, ', multiplying non-finite values (real)' do
    before do
      SyMath.setting(:complex_arithmetic, false)
    end
    
    x = :x.to_m

    # Undetermined
    it 'oo*x == oo*x' do expect(oo*x).to be == oo.mul(x) end
    it 'x*oo == x*oo' do expect(x*oo).to be == x.mul(oo) end

    # NaN
    it 'NaN*10 == NaN'  do expect(nan*10).to be == nan end
    it 'NaN*oo == NaN'  do expect(nan*oo).to be == nan end
    it '10*NaN == NaN'  do expect(10*nan).to be == nan end
    it 'oo*NaN == NaN'  do expect(oo*nan).to be == nan end
    it 'oo*0 == NaN'    do expect(oo*0).to be == nan end
    it '0*oo == NaN'    do expect(0*oo).to be == nan end

    # Same sign
    it 'oo*oo == oo'    do expect(oo*oo).to be == oo end
    it '-oo*-oo = oo'   do expect(-oo*-oo).to be == oo end

    # Oposite sign
    it 'oo*-oo = -oo'   do expect(oo*(-oo)).to be == -oo end
    it '-oo*oo = -oo'   do expect((-oo)*oo).to be == -oo end

    after do
      SyMath.setting(:complex_arithmetic, true)
    end
  end

  describe SyMath::Value, ', dividing non-finite values (complex)' do
    x = :x.to_m

    # Undetermined
    it 'oo/x == oo/x' do expect(oo/x).to be == oo.div(x) end
    it 'x/oo == x/oo' do expect(x/oo).to be == x.div(oo) end

    # NaN
    it 'NaN/10 == NaN' do expect(nan/10).to be == nan end
    it 'NaN/oo == NaN' do expect(nan/oo).to be == nan end
    it '10/NaN == NaN' do expect(10/nan).to be == nan end
    it 'oo/NaN == NaN' do expect(oo/nan).to be == nan end

    # Divide by zero
    it '10/0 == oo'    do expect(10.to_m/0).to be == oo end
    it '0/0 == NaN'    do expect(0.to_m/0).to be == nan end
    it 'oo/0 == oo'   do expect(oo/0).to be == oo end
    it '-oo/0 == oo'  do expect(-oo/0).to be == oo end

    # Divide infinity by infinity
    it 'oo/oo == NaN'  do expect(oo/oo).to be == nan end
    it '-oo/oo == NaN' do expect((-oo)/oo).to be == nan end
    it 'oo/-oo == NaN' do expect(oo/(-oo)).to be == nan end

    # Divide finite by infinity
    it '10/oo == 0'     do expect(10/oo).to be == 0.to_m end
    it '10/-oo == 0'    do expect(10/(-oo)).to be == 0.to_m end
    it '-10/oo == 0'    do expect((-10)/(-oo)).to be == 0.to_m end
    it '-10/-oo == 0'   do expect((-10)/oo).to be == 0.to_m end

    # Divide infinity by finite
    it 'oo/10 == oo'    do expect(oo/10).to be == oo end
    it 'oo/-10 == oo'  do expect(oo/(-10)).to be == oo end
    it '-oo/10 == oo'  do expect((-oo)/10).to be == oo end
    it '-oo/-10 == oo'  do expect((-oo)/(-10)).to be == oo end    
  end

  describe SyMath::Value, ', dividing non-finite values (real)' do
    before do
      SyMath.setting(:complex_arithmetic, false)
    end
    
    x = :x.to_m

    # Undetermined
    it 'oo/x == oo/x' do expect(oo/x).to be == oo.div(x) end
    it 'x/oo == x/oo' do expect(x/oo).to be == x.div(oo) end

    # NaN
    it 'NaN/10 == NaN' do expect(nan/10).to be == nan end
    it 'NaN/oo == NaN' do expect(nan/oo).to be == nan end
    it '10/NaN == NaN' do expect(10/nan).to be == nan end
    it 'oo/NaN == NaN' do expect(oo/nan).to be == nan end

    # Divide by zero
    it '10/0 == NaN'   do expect(10.to_m/0).to be == nan end
    it '0/0 == NaN'    do expect(0.to_m/0).to be == nan end
    it 'oo/0 == NaN'   do expect(oo/0).to be == nan end
    it '-oo/0 == NaN'  do expect(-oo/0).to be == nan end

    # Divide infinity by infinity
    it 'oo/oo == NaN'  do expect(oo/oo).to be == nan end
    it '-oo/oo == NaN' do expect((-oo)/oo).to be == nan end
    it 'oo/-oo == NaN' do expect(oo/(-oo)).to be == nan end

    # Divide finite by infinity
    it '10/oo == 0'     do expect(10/oo).to be == 0.to_m end
    it '10/-oo == 0'    do expect(10/(-oo)).to be == 0.to_m end
    it '-10/oo == 0'    do expect((-10)/(-oo)).to be == 0.to_m end
    it '-10/-oo == 0'   do expect((-10)/oo).to be == 0.to_m end

    # Divide infinity by finite
    it 'oo/10 == oo'    do expect(oo/10).to be == oo end
    it 'oo/-10 == -oo'  do expect(oo/(-10)).to be == -oo end
    it '-oo/10 == -oo'  do expect((-oo)/10).to be == -oo end
    it '-oo/-10 == oo'  do expect((-oo)/(-10)).to be == oo end

    after do
      SyMath.setting(:complex_arithmetic, true)
    end
  end

  describe SyMath::Value, ', power and non-finite values (complex)' do
    oo = :oo.to_m
    nan = :nan.to_m
    x = :x.to_m

    # Undetermined
    it 'oo**x == oo**x' do expect(oo**x).to be == oo.power(x) end
    it 'x**oo == x**oo' do expect(x**oo).to be == x.power(oo) end

    # NaN
    it 'NaN**10 == NaN' do expect(nan**10).to be == nan end
    it 'NaN**oo == NaN' do expect(nan**oo).to be == nan end
    it '10**NaN == NaN' do expect(10**nan).to be == nan end
    it 'oo**NaN == NaN' do expect(oo**nan).to be == nan end

    # Indefinite expressions
    it '1**oo == NaN'    do expect(1**oo).to be == nan end
    it '1**-oo == NaN'   do expect(1**(-oo)).to be == nan end
    it 'oo**0 == NaN'    do expect(oo**0).to be == nan end
    it '-oo**0 == NaN'   do expect((-oo)**0).to be == nan end
    it '0**-oo == NaN'   do expect(0**(-oo)).to be == nan end
    it '-oo**oo == NaN'  do expect((-oo)**oo).to be == nan end

    # Power to negative infinity
    it '10**-oo == NaN'   do expect(10**(-oo)).to be == nan end
    it 'oo**-oo == NaN'   do expect(oo**(-oo)).to be == nan end
    it '-oo**-oo == NaN'  do expect((-oo)**(-oo)).to be == nan end

    # Power of negative infinity
    it '-oo**10 == oo' do expect((-oo)**10).to be == oo end
    
    # Powers with positive infinity
    it 'oo**10 == oo'   do expect(oo**10).to be == oo end
    it '10**oo == NaN'  do expect(10**oo).to be == nan end
    it 'oo**oo == NaN'    do expect(oo**oo).to be == nan end
  end

  describe SyMath::Value, ', power and non-finite values (real)' do
    oo = :oo.to_m
    nan = :nan.to_m
    x = :x.to_m

    before do
      SyMath.setting(:complex_arithmetic, false)
    end
    
    # Undetermined
    it 'oo/x == oo/x' do expect(oo/x).to be == oo.div(x) end
    it 'x/oo == x/oo' do expect(x/oo).to be == x.div(oo) end

    # NaN
    it 'NaN**10 == NaN' do expect(nan**10).to be == nan end
    it 'NaN**oo == NaN' do expect(nan**oo).to be == nan end
    it '10**NaN == NaN' do expect(10**nan).to be == nan end
    it 'oo**NaN == NaN' do expect(oo**nan).to be == nan end

    # Indefinite expressions
    it '1**oo == NaN'   do expect(1**oo).to be == nan end
    it '1**-oo == NaN'  do expect(1**(-oo)).to be == nan end
    it 'oo**0 == NaN'   do expect(oo**0).to be == nan end
    it '-oo**0 == NaN'  do expect((-oo)**0).to be == nan end
    it '0**-oo == NaN'  do expect(0**(-oo)).to be == nan end
    it '-oo**oo == NaN'  do expect((-oo)**oo).to be == nan end

    # Power to negative infinity
    it '10**-oo == 0'   do expect(10**(-oo)).to be == 0 end
    it 'oo**-oo == 0'   do expect(oo**(-oo)).to be == 0 end
    it '-oo**-oo == 0'  do expect((-oo)**(-oo)).to be == 0 end

    # Power of negative infinity
    it '-oo**10 == oo*(-1)**10' do expect((-oo)**10).to be == oo.mul((-1.to_m)**10) end
    
    # Powers with positive infinity
    it 'oo**10 == oo'   do expect(oo**10).to be == oo end
    it '10**oo == oo'   do expect(10**oo).to be == oo end
    it 'oo*oo == oo'    do expect(oo**oo).to be == oo end
    it '(-10.to_m)**oo == NaN' do expect((-10)**oo).to be == nan end

    after do
      SyMath.setting(:complex_arithmetic, true)
    end
  end
end
