require 'spec_helper'

require 'dotstarlib/pulse_filter'

describe DotStarLib::PulseFilter do
  it 'should dim data' do
    f = DotStarLib::PulseFilter.new
    f.set(speed: 1)
    expect(f.process([[0xff0000]])).to eq([[0x010000]])
    expect(f.process([[0xff0000]])).to eq([[0x020000]])
    expect(f.process([[0xff0000]])).to eq([[0x030000]])

    f = DotStarLib::PulseFilter.new
    f.set(speed: 200)
    expect(f.process([[0xff0000]])).to eq([[0xc80000]])
    expect(f.process([[0xff0000]])).to eq([[0x000000]])
  end

  it 'should register itself' do
    expect(DotStarLib::Filter.filters).to include("Pulse" => {clazz: DotStarLib::PulseFilter.class, params: [:speed]})
  end
end
