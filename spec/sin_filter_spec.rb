require 'spec_helper'

require 'dotstarlib/sin_filter'

describe DotStarLib::SinFilter do
  it 'should do sinus on channels' do
    cf = DotStarLib::SinFilter.new
    cf.set(frequency: 1)
    h = cf.process([Array.new(100)])
    expect(h.first.size).to eq(100)
    pp h
    cf.set(frequency: 2)
    h = cf.process([Array.new(100)])
    pp h
  end

  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Sin" => {clazz: DotStarLib::SinFilter.class, params: [:frequency]})
  end
end
