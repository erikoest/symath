require 'spec_helper'
require 'sy'

module Sy
  a = :a.to_m
  b = :b.to_m
  x = :x.to_m
  y = :y.to_m

  describe Sy::Operation::Match do
    matches = [
      {
        :exp1  => x**2 + y**2 + 3,
        :exp2  => a + b,
        :free  => [a, b],
        :match => [
          { a => x**2, b => y**2 + 3 },
          { a => y**2, b => x**2 + 3 },
          { a => 3, b => x**2 + y**2 },
          { a => x**2 + y**2, b => 3 },
          { a => x**2 + 3, b => y**2 },
          { a => y**2 + 3, b => x**2 },
        ]
      },
      {
        :exp1 => :pi.to_m,
        :exp2 => a,
        :free => [a],
        :match => [
          { a => :pi.to_m }
        ]
      },
      {
        :exp1 => fn(:sin, fn(:sin, x))*fn(:cos, fn(:sin, x)),
        :exp2 => fn(:sin, y)*fn(:cos, y),
        :free => [y],
        :match => [
          { y => fn(:sin, x) }
        ]
      },
    ]

    matches.each do |m|
      exp1 = m[:exp1]
      exp2 = m[:exp2]
      free = m[:free]
      m    = m[:match]

      ret = exp1.match(exp2, free)
      it "'#{exp1.to_s}' matches against '#{exp2.to_s}'" do
        expect(ret).to be
        expect(ret.length).to be_equal_to m.length
        
        m.each_with_index do |mi, i|
          mi.keys.each do |k|
            expect(ret[i][k]).to be_equal_to mi[k]
          end
        end
      end
    end
  end
end
