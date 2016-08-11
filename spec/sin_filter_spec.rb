require 'spec_helper'

require 'dotstarlib/sin_filter'

describe DotStarLib::SinFilter do
  it 'should do sinus on channels' do
    cf = DotStarLib::SinFilter.new
    cf.set(frequency: 1, speed: 0)
    h = cf.process(Channel.new(Array.new(100, Value.new(0, 0, 0))))
    expect(h.size).to eq(100)
    cf.set(frequency: 2, speed: 0)
    h = cf.process([Array.new(100)])
  end

  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Sin" => {clazz: DotStarLib::SinFilter.class, params: [:frequency, :speed, :phase]})
  end
end
