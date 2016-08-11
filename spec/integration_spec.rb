require 'spec_helper'

ENV['RACK_ENV'] = 'test'

require 'strip_app'  # <-- your sinatra app
require 'rspec'
require 'rack/test'

describe 'Strip App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "GET /filters should deliver all registered filters" do
    get '/filters'
    expect(last_response).to be_ok
    expect(last_response.body).to eq("{\"Color\":[\"color\"],\"Dim\":[\"factor\"],\"Pulse\":[\"speed\"],\"Sin\":[\"frequency\",\"speed\",\"phase\"]}")
  end
end
