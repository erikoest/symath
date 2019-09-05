require 'spec_helper'
require 'sy'

module Sy
  describe Sy::Value, ', adding non-finite values' do
    oo = :oo.to_m
    nan = :NaN.to_m

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
  end

  describe Sy::Value, ', multiplying non-finite values' do
    oo = :oo.to_m
    nan = :NaN.to_m

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
  end

  describe Sy::Value, ', dividing non-finite values' do
    oo = :oo.to_m
    nan = :NaN.to_m

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
  end

  describe Sy::Value, ', power and non-finite values' do
    oo = :oo.to_m
    nan = :NaN.to_m

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

    # Power to negative infinity
    it '10**-oo == 0'   do expect(10**(-oo)).to be == 0 end
    it 'oo**-oo == 0'   do expect(oo**(-oo)).to be == 0 end
    it '-oo**-oo == 0'  do expect((-oo)**(-oo)).to be == 0 end

    # Power of negative infinity
    it '-oo**10 == -oo' do expect((-oo)**10).to be == -oo end
    it '-oo*oo == -oo'  do expect((-oo)**oo).to be == -oo end
    
    # Powers with positive infinity
    it 'oo**10 == oo'   do expect(oo**10).to be == oo end
    it '10**oo == oo'   do expect(10**oo).to be == oo end
    it 'oo*oo == oo'    do expect(oo**oo).to be == oo end
  end
end
