require 'spec_helper'

require 'dotstarlib/color_filter'

describe DotStarLib::ColorFilter do
  it 'should create constant color data' do
    cf = DotStarLib::ColorFilter.new
    cf.set(color: 0xff0000)
    expect(cf.process([[1,2,3]])).to eq([[0xff0000, 0xff0000, 0xff0000]])
  end
  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Color" => {clazz: DotStarLib::ColorFilter.class, params: [:color]})
  end
end
