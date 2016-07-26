require 'spec_helper'

require 'dotstarlib/dim_filter'

describe DotStarLib::DimFilter do
  it 'should dim on channels' do
    cf = DotStarLib::DimFilter.new
    expect(cf.dim_channel(255, 127)).to eq(127)
    expect(cf.dim_channel(255, 64)).to eq(64)
    expect(cf.dim_channel(128, 64)).to eq(32)
  end

  it 'should dim data' do
    cf = DotStarLib::DimFilter.new
    cf.set(factor: 127)
    expect(cf.process([[0xff0000,0x00ff00,0x0000ff]])).to eq([[0x7f0000,0x007f00,0x00007f]])
  end

  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Dim" => {clazz: DotStarLib::DimFilter.class, params: [:factor]})
  end
end
