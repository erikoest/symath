#!/usr/bin/ruby

require 'sy'

m = Sy::SumMultiplication.new
n = Sy::Normalization.new

# e = -:x.to_m*(-:y.to_m - 3.to_m)
# e = 3.to_m* -:x.to_m
e = (-:y.to_m)*(-:x.to_m) - (3.to_m*(-:x.to_m))

# puts m.act(e).to_s
puts n.act(e).to_s
