require 'dotstarlib/filters'
require 'dotstarlib/sin_filter'

s = SinFilter.new
s.set(frequency: 2)

strip = DotStarStrip.new(30)
res = s.process([Array.new(30)])
res.each_with_index do |c, i|
  strip.set_pixel(i, c << 16 | c << 8 | c)
end
strip.refresh
