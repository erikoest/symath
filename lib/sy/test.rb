#!/usr/bin/ruby

require 'sy'

n = Sy::Normalization.new
d = Sy::DistributiveLaw.new

a = 3.to_m/4 + (5.to_m + 2)/34
b = d.act(a)
c = n.act(a)

puts a
puts b
puts c
