require 'spec_helper'
require 'symath'

module SyMath
  describe SyMath::Type do
    x = :x.to_m
    y = :y.to_m
    vx = :x.to_m('vector')
    vy = :y.to_m('vector')
    vz = :z.to_m('vector')
    dx = :tx.to_m('dform')
    dy = :ty.to_m('dform')
    dz = :tz.to_m('dform')
    m53 = :m.to_m(SyMath::Type.new('matrix', dimn: 3, dimm: 5))
    m32 = :m.to_m(SyMath::Type.new('matrix', dimn: 2, dimm: 3))

    it 'real and integer has real as common parent' do
      int = 'integer'.to_t
      real = 'real'.to_t
      expect(int.common_parent(real).name).to be == :real
    end

    it 'rational and imaginary has complex as common parent' do
      rat = 'rational'.to_t
      im = 'imaginary'.to_t
      expect(rat.common_parent(im).name).to be == :complex
    end

    it 'wedge product of mixed vector and dform' do
      w = :a.to_m('vector').wedge(:db.to_m('dform'))
      expect(w.type).to be == 'tensor'.to_t(indexes: ['u', 'l'])
    end

    it 'wedge product of mixed scalar and vector' do
      w = :a.to_m('vector').wedge(:b.to_m)
      expect(w.type).to be == 'vector'.to_t
    end

    it 'wedge product of mixed scalar and dform' do
      w = :da.to_m('dform').wedge(:b.to_m)
      expect(w.type).to be == 'dform'.to_t
    end

    it 'vector and dform has no common parent' do
      expect { vx.type.common_parent(dx.type) }.to raise_error 'No common type for vector[u] and dform[l]'
    end

    it 'matrix and scalar types cannot be summed' do
      expect { m32.type.sum(x.type) }.to raise_error 'Types matrix[3x2] and real cannot be summed.'
    end

    it 'product of matrices' do
      expect(m53.type.product(m32.type).to_s).to be_equal_to 'matrix[5x2]'
    end

    it 'product of matrices failure' do
      expect { m32.type.product(m53.type) }.to raise_error 'Types matrix[3x2] and matrix[5x3] cannot be multiplied'
    end

    it 'degree of vector/dform product' do
      expect((vx^vy^dx^dy).type.degree).to be == 4
    end

    it 'product of dforms is nform' do
      expect((dx^dy).type.is_nform?).to be == true
    end

    it 'product of vector and dform is not nform' do
      expect((vx^dx).type.is_nform?).to be == false
    end

    it 'dform is not a covector' do
      expect(dx.type.is_covector?).to be == false
    end

    it '2-form is a pseudovector in a 3d basis' do
      expect((dx^dy).type.is_pseudovector?).to be == true
    end

    it '2-vector is a pseudovector in a 3d basis' do
      expect((vx^vy).type.is_pseudovector?).to be == true
    end

    it 'dform is not a pseudovector in a 3d basis' do
      expect(dx.type.is_pseudovector?).to be == false
    end

    it 'vector is not a pseudovector in a 3d basis' do
      expect(vx.type.is_pseudovector?).to be == false
    end

    it 'matrix is not a pseudovector' do
      expect(m32.type.is_pseudovector?).to be == false
    end

    it '3-form is a pseudoscalar in a 3d basis' do
      expect((dx^dy^dz).type.is_pseudoscalar?).to be == true
    end

    it '3-vector is a pseudoscalar in a 3d basis' do
      expect((vx^vy^vz).type.is_pseudoscalar?).to be == true
    end

    it 'dform is not a pseudoscalar' do
      expect(dx.type.is_pseudoscalar?).to be == false
    end

    it 'vector is not a pseudoscalar' do
      expect(vx.type.is_pseudoscalar?).to be == false
    end

    it 'matrix is not a pseudoscalar' do
      expect(m32.type.is_pseudoscalar?).to be == false
    end

    it 'index of wedge product' do
      expect((dx^dy^vx^vy).type.index_str).to be_equal_to '..\'\''
    end
  end
end
