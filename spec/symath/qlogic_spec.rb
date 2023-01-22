require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Operation::Normalization, ', reduce exp (real)' do
    before do
      SyMath.setting(:braket_syntax, true)
      SyMath.set_default_vector_space('quantum_logic')
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
      'qH|0>'       => '|+>',
      'qS qS'       => 'qZ',
      'qS qS qS qS' => '1',
      'qCNOT|0>|0>' => '|0,0>',
      'qCNOT|0>|1>' => '|0,1>',
      'qCNOT|1>|0>' => '|1,1>',
      'qCNOT|1>|1>' => '|1,0>',
      'qCNOT|1>|+>' => '|1,+>',
      'qCNOT|1>|->' => '-|1,->',
      '|1>|0>'      => '|1,0>',
      'Herm(|x>)'        => '<x|',
      'Herm(|x,y>)'      => '<y,x|',
      'Herm(Herm(a))'    => 'a',
      'Herm(qX)'         => 'qX',
      'Herm(qX|a>)'      => '<a|qX',
      'Herm(qX|a>)qX|a>' => '1',
    }

    exp.each do |from, to|
      it "reduces '#{from}' to '#{to}'" do
        expect(from.to_m.normalize).to be_equal_to to.to_m
      end
    end

    # Calculate expressions by converting them to matrices
    exp_mx = {
      'qX qY qZ'    => [[:i, 0], [0, :i]],
      'qS qS qS qS' => [[1, 0], [0, 1]],
      'qX|0>'       => [[0], [1]],
    }

    exp_mx.each do |from, to|
      it "calculates '#{from}' to '#{to}'" do
        expect(from.to_m.to_matrix.calc_mx.normalize).to be_equal_to to.to_m
      end
    end
    
    after do
      SyMath.setting(:braket_syntax, false)
      SyMath.set_default_vector_space('euclidean_3d')
    end
  end
end
