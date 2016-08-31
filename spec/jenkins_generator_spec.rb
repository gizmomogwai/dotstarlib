require 'spec_helper'

require 'dotstarlib/jenkins_generator'

describe DotStarLib::JenkinsGenerator do
  it 'should get channels with jobs from cwg3 and jenkins' do
    g = DotStarLib::JenkinsGenerator.new(10, ['cgw3'], ['audi-cgw', 'huawei-kernel'], DotStarLib::NoPulse.new)
    res = g.process(nil)
    expect(res.values.size).to eq(3)
    expect(res.values).to eq([0xff00ff00, 0xffff0000, 0xffff00ff])
  end
end
