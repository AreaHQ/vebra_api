# frozen_string_literal: true

module Vebra
  class Config
    DEFAULT_BASE_URI = 'http://webservices.vebra.com/export'

    attr_accessor :base_uri, :username, :password, :data_feed_id, :debug
    attr_writer :cache

    def initialize(params = {})
      @base_uri =     params[:base_uri] || DEFAULT_BASE_URI
      @username =     params[:username]
      @password =     params[:password]
      @data_feed_id = params[:data_feed_id]
      @debug =        params[:debug]
      @cache =        params[:cache]
    end

    def uri
      "#{base_uri}/#{data_feed_id}/v11"
    end

    def cache
      @cache ||= FileCache.new(self)
    end

    def debugging?
      debug
    end

    def to_h
      {
        data_feed_id: data_feed_id
      }
    end
  end
end
