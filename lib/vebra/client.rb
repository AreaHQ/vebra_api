# frozen_string_literal: true

require 'forwardable'

module Vebra
  class Client
    include API
    extend Forwardable

    attr_reader :auth, :config, :branch
    def_delegators :config, :username, :password, :data_feed_id, :debugging?

    # client = Vebra::Client.new(:data_feed_id => 'ABC', :username => 'user', :password => 'pass')

    def initialize(config)
      @config = config.is_a?(Config) ? config : Config.new(config)

      return if data_feed_id && username && password

      raise '[Vebra]: configuration hash must include `data_feed_id`, `username`, and `password`'
    end

    # Proxy to call the appropriate method (or url) via the Vebra::API module
    def call(url_or_method, interpolations = {})
      if url_or_method.is_a?(Symbol)
        raw = send("#{url_or_method}_url")
        url = compile(raw, config, interpolations)
      end

      get(url || url_or_method, @auth)
    end

    # Call the API method to retrieve a collection of branches for this client,
    # and build a Vebra::Branch object for each
    def get_branches
      xml = call(:branches).parsed_response
      xml.css('branches branch').map { |b| Branch.new(self, b) }
    end

    private

    def debug_log(message)
      return unless debugging?

      puts "[Vebra]: #{message}"
    end
  end
end
