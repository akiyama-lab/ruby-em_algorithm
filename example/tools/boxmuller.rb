#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
##ボックスミュラー法によるガウス分布データ生成
##偶数個しか作れない仕様であることに注意

require 'yaml'

include Math
def boxmuller(n,mu,sigma)
  j=0
  data_array = []
  while j < n
    a=rand()
    b=rand()
    r1=sqrt(-2*Math.log(a.to_f)).to_f*sin(2*Math::PI*b.to_f).to_f
    r2=sqrt(-2*Math.log(a.to_f)).to_f*cos(2*Math::PI*b.to_f).to_f
    r3=r1.to_f*sigma.to_f+mu.to_f
    r4=r2.to_f*sigma.to_f+mu.to_f
    data_array << r3
    data_array << r4
    j=j+2
  end
  data_array
end

data_array = boxmuller(7000, 5, 4.0)
data_array = data_array + boxmuller(3000, -5, 1.0)
puts data_array.to_yaml
