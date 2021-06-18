require 'spec_helper'
require 'sy'

module Sy
  a = :a.to_m
  b = :b.to_m
  c = :c.to_m
  x = :x.to_m
  y = :y.to_m
  z = :z.to_m

  describe Sy::Operation::Match do
    matches = [
      {
        :exp1 => :pi.to_m,
        :exp2 => :pi.to_m,
        :match => [
          {}
        ],
      },
      {
        :exp1 => :pi.to_m,
        :exp2 => :e.to_m,
        :match => nil,
      },
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
        :exp1  => :pi.to_m,
        :exp2  => a,
        :free  => [a],
        :match => [
          { a => :pi.to_m }
        ]
      },
      {
        :exp1  => fn(:sin, fn(:sin, x))*fn(:cos, fn(:sin, x)),
        :exp2  => fn(:sin, y)*fn(:cos, y),
        :free  => [y],
        :match => [
          { y => fn(:sin, x) }
        ]
      },
      {
        :exp1  => op(:op1, op(:op1, x, y), z),
        :exp2  => op(:op1, op(:op1, a, b), c),
        :free  => [a, b, c],
        :match => [
          { a => x, b => y, c => z },
        ],
      },
      {
        :exp1  => :pi.to_m + 3 + :e.to_m,
        :exp2  => :e.to_m + a,
        :free  => [a],
        :match => [
          { a => :pi.to_m + 3 },
        ],
      },
      {
        :exp1  => :pi.to_m + 3 + :e.to_m,
        :exp2  => :e.to_m + a,
        :bound =>
          { a => :pi.to_m + 4 },
        :match => nil,
      },
      {
        :exp1  => a + b,
        :exp2  => a + b,
        :match => [
          {},
        ],
      },
    ]

    matches.each do |m|
      exp1  = m[:exp1]
      exp2  = m[:exp2]
      free  = m.has_key?(:free) ? m[:free] : []
      bound = m.has_key?(:bound) ? m[:bound] : {}
      m     = m[:match]
      

      ret = exp1.match(exp2, free, bound)
      txt = m.nil? ? 'does not match against' : 'matches against'

      it "'#{exp1.to_s}' #{txt} '#{exp2.to_s}'" do
        if m.nil?
          expect(ret).to be_nil
        else
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
end
