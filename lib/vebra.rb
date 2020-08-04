# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'nokogiri'
require 'nori'
require 'vebra/config'
require 'vebra/api'
require 'vebra/response'
require 'vebra/client'
require 'vebra/model'
require 'vebra/branch'
require 'vebra/property'
require 'vebra/file_cache'
require 'vebra/redis_cache'
require 'vebra/version'

module Vebra
  def self.config(&config_block)
    config = client&.config || Config.new
    config_block[config]
    @client = Client.new(config)
  end

  def self.client
    @client
  end
end

module Net
  module HTTPHeader
    def basic_token(token)
      @header['authorization'] = [basic_encode_token(token)]
    end

    def basic_encode_token(token)
      result = 'Basic ' + [token.to_s].pack('m').delete("\r\n")
      result
    end
    private :basic_encode_token
  end
end
