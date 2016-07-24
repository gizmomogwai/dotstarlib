require 'json'

require 'sinatra'
require 'dotstarlib'

get '/filters' do
  DotStarLib::Filter.filters.inject({}) { |memo, data|
    memo[data.first] = data[1][:params]
    memo
  }.to_json
end
