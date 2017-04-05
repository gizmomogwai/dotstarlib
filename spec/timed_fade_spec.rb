require 'spec_helper'

require 'dotstarlib/timed_fade_generator'

include DotStarLib

describe DotStarLib::TimedFadeGenerator do
  it 'should calculate the correct delta for all alarms' do
    expect(Moment.new(23, 30).delta_to(Moment.new(01, 00))).to eq( 90*60)
    expect(Moment.new(02, 30).delta_to(Moment.new(01, 00))).to eq(-90*60)
  end

  it 'should fade before the alarm' do
    uut = TimedFadeGenerator.new()
    at_six = Moment.new(06, 00)
    expect(uut.factor_for(Moment.new(05, 45), at_six, 300)).to eq(0.0)
    expect(uut.factor_for(Moment.new(05, 56), at_six, 300)).to eq(0.2)
    expect(uut.factor_for(Moment.new(05, 59), at_six, 300)).to eq(0.8)
    expect(uut.factor_for(Moment.new(06, 00), at_six, 300)).to eq(1.0)

    one_after_midnight = Moment.new(00, 01)
    expect(uut.factor_for(Moment.new(23, 58), one_after_midnight, 300)).to eq(0.4)
    expect(uut.factor_for(Moment.new(23, 59), one_after_midnight, 300)).to eq(0.6)

    midnight = Moment.new(00, 00)
    expect(uut.factor_for(Moment.new(23, 54), midnight, 300)).to eq(0.0)
    expect(uut.factor_for(Moment.new(23, 56), midnight, 300)).to eq(0.2)
    expect(uut.factor_for(Moment.new(23, 57), midnight, 300)).to eq(0.4)
    expect(uut.factor_for(Moment.new(23, 59), midnight, 300)).to eq(0.8)
  end

  it 'should be 1 for a time after the alarm' do
    uut = TimedFadeGenerator.new()
    six = Moment.new(06, 00)
    expect(uut.factor_for(Moment.new(06, 01), six, 300)).to eq(1.0)
    expect(uut.factor_for(Moment.new(06, 04), six, 300)).to eq(1.0)
    expect(uut.factor_for(Moment.new(06, 06), six, 300)).to eq(0.0)
  end

  it 'should fade on channels' do
    uut = TimedFadeGenerator.new
    uut.set(alarm: "06:00", fade: 300, time: "05:59")
    size = 10
    h = uut.process(Channel.new(Array.new(size, Value.new(100, 0, 0))))
    expect(h.size).to eq(size)
    expect(h).to eq(Channel.new([Value.new(80, 0, 0)] * size))
  end
end
