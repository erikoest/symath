require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Operation::Normalization, ', reduce exp (real)' do
    before do
      SyMath.setting(:braket_syntax, true)
    end

    exp = {
      '<a|a>' => '1',
      '<0|1>' => '0',
      '<1|0>' => '0',
      '<+|->' => '0',
      '<-|+>' => '0',
      '<R|L>' => '0',
      '<L|R>' => '0',
      '<1|1>' => '1',
      '<0|0>' => '1',
      '<+|+>' => '1',
      'qX|0>' => '|1>',
      'qX|1>' => '|0>',
      'qX|->' => '|+>',
      'qX|+>' => '|->',
      'qX|R>' => '|R>',
      'qX|L>' => '|L>',
      'qX qX' => '1',
      '<0|qX|1>'    => '1',
      'qX qY qZ'    => 'i',
      'qX qZ qY'    => '- i',
      '<0|qY'       => '-i <1|',
      'qS qS'       => 'qZ',
      'qS qS qS qS' => '1',
    }

    exp.each do |from, to|
      it "reduces '#{from}' to '#{to}'" do
        expect(from.to_m.normalize).to be_equal_to to
      end
    end
    
    after do
      SyMath.setting(:braket_syntax, false)
    end
  end
end
