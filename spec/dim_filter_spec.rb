require 'spec_helper'

require 'dotstarlib/dim_filter'

describe DotStarLib::DimFilter do
  it 'should dim on channels' do
    cf = DotStarLib::DimFilter.new
    expect(cf.dim(255, 127)).to eq(127)
    expect(cf.dim(255, 64)).to eq(64)
    expect(cf.dim(128, 64)).to eq(32)
  end

  it 'should dim data' do
    cf = DotStarLib::DimFilter.new
    cf.set(factor: 127)
    expect(cf.process(Channel.new([Value.new(255, 0, 0), Value.new(0, 255, 0), Value.new(0, 0, 255)]))).to eq(Channel.new([Value.new(127, 0, 0), Value.new(0, 127, 0), Value.new(0, 0, 127)]))
  end

  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Dim" => {clazz: DotStarLib::DimFilter.class, params: [:factor]})
  end
end
