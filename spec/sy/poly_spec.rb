require 'spec_helper'
require 'sy'

module Sy
  # Convert structure of expressions to string
  def Sy.atos(s)
    if s.is_a?(Array)
      return '['+ s.map { |e| Sy.atos(e) }.join(', ') + ']'
    else
      return s.to_s
    end
  end

  describe Sy::Poly::DUP do
    # Map expression to dup
    def d(exp)
      if exp.is_a?(Array)
        return exp.map { |i| Sy::Poly::DUP.new(i) }
      end
      
      return Sy::Poly::DUP.new(exp)
    end

    # Map dup (or structure of dups) to expression
    def e(dup)
      if dup.is_a?(Array)
        return dup.map { |i| e(i) }
      end

      return dup.to_m
    end

    x = :x.to_m

    context 'Conversions' do
      ex = 3*x**3 - 2*x + 1000
      poly = [3, 0, -2, 1000]

      it "Exp to array, #{ex} => #{poly}" do
        expect(d(ex).arr).to be == poly
      end

      it "Array to exp, #{poly} => #{ex}" do
        expect(d(ex).to_m).to be == ex
      end
    end

    context 'Pseudo-remainder' do
      f = 3*x**3 + x**2 + x + 5
      g = 5*x**2 - 3*x + 1
      r = 52*x + 111

      it "(#{f}, #{g}) => #{r}" do
        expect(e(d(f).pseudo_rem(d(g)))).to be == r
      end
    end

    context 'Subresultant' do
      f = x**8 + x**6 - 3*x**4 - 3*x**3 + 8*x**2 + 2*x - 5
      g = 3*x**6 + 5*x**4 - 4*x**2 - 9*x + 21
      r = [f, g, 15*x**4 - 3*x**2 + 9, 65*x**2 + 125*x - 245, 9326*x - 12300, 260708.to_m]

      it "(#{f}, #{g}) => #{Sy.atos(r)})" do
        expect(e(d(f).subresultants(d(g)))).to be == r
      end
    end

    context 'Division' do
      f1 = 5*x**4 + 4*x**3 + 3*x**2 + 2*x + 1
      g1 = x**2 + 2*x + 3
      r1 = [5*x**2 - 6*x, 20*x + 1]
      
      it "(#{f1}, #{g1}) => #{Sy.atos(r1)}" do
        expect(e(d(f1).div(d(g1)))).to be == r1
      end

      f2 = 5*x**5 + 4*x**4 + 3*x**3 + 2*x**2 + x
      g2 = x**4 + 2*x**3 + 9
      r2 = [5*x - 6, 15*x**3 + 2*x**2 - 44*x + 54]

      it "(#{f2}, #{g2}) => #{Sy.atos(r2)}" do
        expect(e(d(f2).div(d(g2)))).to be == r2
      end
    end

    context 'Differentiation' do
      f1 = x**2 + 2*x + 1
      r1 = 2*x + 2

      it "#{f1} => #{r1}" do
        expect(e(d(f1).diff)).to be == r1
      end

      f2 = x**3 + 2*x**2 + 3*x + 4
      r2 = 3*x**2 + 4*x + 3

      it "#{f2} => #{r2}" do
        expect(e(d(f2).diff)).to be == r2
      end
    end

    context 'Gcd' do
      f1 = x**8 + x**6 - 3*x**4 - 3*x**3 + 8*x**2 + 2*x - 5
      g1 = 3*x**6 + 5*x**4 - 4*x**2 - 9*x + 21
      r1 = [1.to_m, f1, g1]

      it "(#{f1}, #{g1}) => #{Sy.atos(r1)}" do
        expect(e(d(f1).gcd(d(g1)))).to be == r1
      end
      
      f2 = x**2 - 1
      g2 = x**2 - 3*x + 2
      r2 = [x - 1, x + 1, x - 2]

      it "(#{f2}, #{g2}) => [#{Sy.atos(r2)}" do
        expect(e(d(f2).gcd(d(g2)))).to be == r2
      end
    end

    context 'Sqf part' do
      f1 = x**3 + x + 1
      r1 = x**3 + x + 1

      it "#{f1} => #{r1}" do
        expect(e(d(f1).sqf_part)).to be == r1
      end

      f2 = -x**3 + x + 1
      r2 = x**3 - x - 1

      it "#{f2} => #{r2}" do
        expect(e(d(f2).sqf_part)).to be == r2
      end

      f3 = 2*x**3 + 3*x**2
      r3 = 2*x**2 + 3*x

      it "#{f3} => #{r3}" do
        expect(e(d(f3).sqf_part)).to be == r3
      end

      f4 = -(2*x**3) + 3*x**2
      r4 = 2*x**2 - 3*x

      it "#{f4} => #{r4}" do
        expect(e(d(f4).sqf_part)).to be == r4
      end
    end

    context 'Sqf list' do
      f1 = -x**5 + x**4 + x - 1
      r1 = [-1, [[x**3 + x**2 + x + 1, 1], [x - 1, 2]]]

      it "#{f1} => #{Sy.atos(r1)}" do
        expect(e(d(f1).sqf_list)).to be == r1
      end

      f2 = x**8 + 6*x**6 + 12*x**4 + 8*x**2
      r2 = [1, [[x, 2], [x**2 + 2, 3]]]

      it "#{f2} => #{Sy.atos(r2)}" do
        expect(e(d(f2).sqf_list)).to be == r2
      end

      f3 = 2*x**2 + 4*x + 2
      r3 = [2, [[x + 1, 2]]]

      it "#{f3} => #{Sy.atos(r3)}" do
        expect(e(d(f3).sqf_list)).to be == r3
      end
    end

    context "Factorization" do
      tests = [
        { :f => x**2 + 2*x + 2,
          :r => [1, [[x**2 + 2*x + 2, 1]]],
        },
        { :f => 18*x**2 + 12*x + 2,
          :r => [2, [[3*x + 1, 2]]]
        },
	{ :f => -9*x**2 + 1,
          :r => [-1, [[3*x - 1, 1], [3*x + 1, 1]]],
        },
        { :f => x**3 - 6*x**2 + 11*x - 6,
          :r => [1, [[x - 3, 1], [x - 2, 1], [x - 1, 1]]],
        },
        { :f => 3*x**3 + 10*x**2 + 13*x + 10,
          :r => [1, [[x + 2, 1], [3*x**2 + 4*x + 5, 1]]],
        },
        { :f => -x**6 + x**2,
          :r => [-1, [[x - 1, 1], [x + 1, 1],
                      [x, 2], [x**2 + 1, 1]]],
        },
        { :f => 1080*x**8 + 5184*x**7 + 2099*x**6 + 744*x**5 +
                2736*x**4 - 648*x**3 + 129*x**2 - 324,
          :r => [1, [[5*x**4 + 24*x**3 + 9*x**2 + 12, 1],
                     [216*x**4 + 31*x**2 - 27, 1]]]
        },
        { :f => -29802322387695312500000000000000000000*x**25 +
                2980232238769531250000000000000000*x**20 +
                1743435859680175781250000000000*x**15 +
                114142894744873046875000000*x**10 -
                210106372833251953125*x**5 +
                95367431640625,
          :r => [-95367431640625,
                 [[5*x - 1, 1],
                  [100*x**2 + 10*x - 1, 2],
                  [625*x**4 + 125*x**3 + 25*x**2 + 5*x + 1, 1],
                  [10000*x**4 - 3000*x**3 + 400*x**2 - 20*x + 1, 2],
                  [10000*x**4 + 2000*x**3 + 400*x**2 + 30*x + 1, 2]]],
        },
      ]
      
      tests.each do |t|
        it "#{t[:f]} => #{Sy.atos(t[:r])}" do
          expect(e(d(t[:f]).factor)).to be == t[:r]
        end
      end
    end
  end

  describe Sy::Poly::Galois do
    x = :x.to_m

    # Map array to galois poly
    def g(a, p)
      return Sy::Poly::Galois.new({ :arr => a, :p => p, :var => :x.to_m })
    end

    # Map galois poly (or structure of polys) to array
    def a(g)
      if g.is_a?(Array)
        return g.map { |e| a(e) }
      elsif g.is_a?(Sy::Poly::Galois)
        return g.arr
      else
        return g
      end
    end
    
    context 'Conversions' do
      dup = Sy::Poly::DUP.new(x**4 + 7*x**2 + 2*x + 20)

      it "dup to gl" do
        gl = Sy::Poly::Galois.new({ :dup => dup, :p => 5 })
        expect(gl.arr).to be == [1, 0, 2, 2, 0]
      end

      it "gl to dup" do
        expect(g([1, 0, 4, 2, 3], 5).to_dup.arr).to be == [1, 0, -1, 2, -2]
      end
    end

    context 'Division' do
      f = [5, 4, 3, 2, 1, 0]
      d1 = [1, 2, 3]
      q1 = [5, 1, 0, 6]
      r1 = [3, 3]
      
      it "(#{f}, #{d1}) => (#{q1}, #{r1})" do
        expect(a(g(f, 7).div(g(d1, 7)))).to be == [q1, r1]
      end

      d2 = [1, 2, 3, 0]
      q2 = [5, 1, 0]
      r2 = [6, 1, 0]
      
      it "(#{f}, #{d2}) => (#{q2}, #{r2})" do
        expect(a(g(f, 7).div(g(d2, 7)))).to be == [q2, r2]
      end
    end

    context 'Gcdex' do
      f1 = [3, 0]
      d1 = [3, 0]
      r1 = [[], [4], [1, 0]]

      it "(#{f1}, #{d1}) => #{r1}" do
        expect(a(g(f1, 11).gcdex(g(d1, 11)))).to be == r1
      end
      
      f2 = [1, 8, 7]
      d2 = [1, 7, 1, 7]
      r2 = [[5, 6], [6], [1, 7]]
      
      it "(#{f2}, #{d2}) => #{r2}" do
        expect(a(g(f2, 11).gcdex(g(d2, 11)))).to be == r2
      end
    end

    context 'Gcd' do
      f1 = [3, 0]
      d1 = [3, 0]
      r1 = [1, 0]

      it "(#{f1}, #{d1}) => #{r1}" do
        expect(a(g(f1, 11).gcd(g(d1, 11)))).to be == r1
      end
      
      f2 = [1, 8, 7]
      d2 = [1, 7, 1, 7]
      r2 = [1, 7]
      
      it "(#{f2}, #{d2}) => #{r2}" do
        expect(a(g(f2, 11).gcd(g(d2, 11)))).to be == r2
      end
    end

    context 'Differentiation' do
      f = [7, 3, 1]
      r = [3, 3]

      it "#{f} => #{r}" do
        expect(a(g(f, 11).diff)).to be == r
      end
    end

    context 'Factorization' do
      f1 = [1, 0, 0, 1, 0]
      r1 = [1,
            [[[1, 0], 1],
             [[1, 1], 1],
             [[1, 1, 1], 1]]]

      it "#{f1} => #{r1}" do
        expect(a(g(f1, 2).factor)).to be == r1
      end

      f2 = [1, -3, 1, -3, -1, -3, 1]
      r2 = [1,
            [[[1, 1], 1],
             [[1, 5, 3], 1],
             [[1, 2, 3, 4], 1]]]

      it "#{f2} => #{r2}" do
        expect(a(g(f2, 11).factor)).to be == r2
      end
    end
  end
end
