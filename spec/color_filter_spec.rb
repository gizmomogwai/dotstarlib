require 'spec_helper'

require 'dotstarlib/color_filter'
include DotStarLib

describe ColorFilter do
  it 'should create constant color data' do
    cf = ColorFilter.new
    cf.set(color: 0xff0000)
    channel = Channel.new([Value.new(0, 0, 0), Value.new(1, 1, 1), Value.new(2, 2, 2)])
    expect(cf.process(channel)).to eq(Channel.new([Value.new(255, 0, 0), Value.new(255, 0, 0), Value.new(255, 0, 0)]))
  end

  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Color" => {clazz: DotStarLib::ColorFilter.class, params: [:color]})
  end
end
