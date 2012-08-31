#
# ADNRuby - A simple and easy to use App.net Ruby library
#
# Copyright (c) 2012 Kishyr Ramdial
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'net/https'
require 'uri'
require 'json'
require 'date'

%w{api post user version}.each { |f| require_relative "adn/#{f}" }

module ADN
  API_HOST = "alpha-api.app.net"
  HTTP = Net::HTTP.new(API_HOST, 443)
  HTTP.use_ssl = true

  class << self
    attr_accessor :auth_url, :access_token_url, :client_id, :client_secret, :redirect_uri, :scopes
    attr_accessor :token

    def configure
      yield self
      self
    end

    def authorize_url
      "#{ADN.auth_url}?client_id=#{ADN.client_id}&response_type=code&redirect_uri=#{URI.escape(ADN.redirect_uri)}&scope=#{ADN.scopes.join('+')}"
    end

    def get_access_token(code)
      uri = URI.parse(ADN.access_token_url)
      params = { "client_id" => ADN.client_id, "client_secret" => ADN.client_secret, "grant_type" => "authorization_code", "redirect_uri" => ADN.redirect_uri, "code" => code }
      http = Net::HTTP.new(uri.host, 443)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.path)
      request.add_field("ContentType", "text/xml")
      request.set_form_data(params)
      response = http.request(request)
      JSON.parse(response.body)
    end
  end

  private

  def self.get_response(request)
    request.add_field("Authorization", "Bearer #{ADN.token}")
    response = ADN::HTTP.request(request)
    JSON.parse(response.body)
  end

  def self.get(url, params = nil)
    get_url = params.nil? ? url : "#{url}?#{URI.encode_www_form(params)}"
    self.get_response(Net::HTTP::Get.new(get_url))
  end

  def self.post(url, params = nil)
    request = Net::HTTP::Post.new(url)
    request.set_form_data(params) if params
    self.get_response(request)
  end

  def self.put(url, params = nil)
    request = Net::HTTP::Put.new(url)
    request.set_form_data(params) if params
    self.get_response(request)
  end

  def self.delete(url, params = nil)
    request = Net::HTTP::Delete.new(url)
    self.get_response(request)
  end
end

class Hash
  def has_error?
    self.has_key? "error"
  end
end
