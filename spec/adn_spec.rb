# encoding: UTF-8

require 'YAML'
require_relative 'spec_helper'

File.open('adn.yml', 'r') do |f|
  ADN_CONFIG = YAML.load(f)
end

describe ADN do
  subject { ADN }

  let(:example_token) {
    'f1d2d2f924e986ac86fdf7b36c94bcdf32beec15'
  }

  before do
    ADN.configure do |config|
      config.auth_url         = ADN_CONFIG['auth_url']
      config.access_token_url = ADN_CONFIG['access_token_url']
      config.client_id        = ADN_CONFIG['client_id']
      config.client_secret    = ADN_CONFIG['client_secret']
      config.redirect_uri     = ADN_CONFIG['redirect_uri']
      config.scopes           = ADN_CONFIG['scopes']
    end
  end

  it "should generate a valid authorize url" do
    ADN.authorize_url.must_equal "https://alpha.app.net/oauth/authenticate?client_id=es3kBCA3AqdyD3S8DAn6frVg4GmCtT49&response_type=code&redirect_uri=http://127.0.0.1.xip.io:3000/callback&scope=stream+email+write_post+follow+messages+export"
  end

  it "can set and get a token" do
    subject.token.must_equal nil
    subject.token = example_token
    subject.token.must_equal example_token
  end

  it "has a constant containing the hostname of the api" do
    ADN::API_HOST.must_equal 'alpha-api.app.net'
  end

  it "has constants containing the API endpoints for posts and users" do
    ADN::API_ENDPOINT_POSTS.must_equal '/stream/0/posts'
    ADN::API_ENDPOINT_USERS.must_equal '/stream/0/users'
  end

  it "has constants containing the API endpoints for tokens" do
    ADN::API_ENDPOINT_TOKEN.must_equal '/stream/0/token'
  end

  # TODO: Move into the ADN module, and rename using snake case
  #       Should probably be refactored to a separate class
  it "currently has a constant containing a http client" do
    ADN::HTTP.tap { |http|
      http.address.must_equal "alpha-api.app.net"
      http.port.must_equal 443
      http.use_ssl?.must_equal true
    }
  end
end
