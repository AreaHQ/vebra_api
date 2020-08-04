# frozen_string_literal: true

module Vebra
  class RedisCache
    attr_reader :redis_client, :config

    def initialize(config, redis_client)
      @redis_client = redis_client
      @config = config
    end

    def get(key)
      value = redis_client.get(redis_key(key))
      return value unless value.nil? && block_given?

      value = yield
      set(key, value)
      value
    end

    def set(key, value)
      redis_client.set(redis_key(key), value)
    end

    def delete(key)
      redis_client.del(redis_key(key))
    end

    private

    def redis_key(key)
      "#{redis_key_prefix}-#{key}"
    end

    def redis_key_prefix
      @redis_key_prefix ||= "Vebra-#{config.base_uri}-#{config.data_feed_id}"
    end
  end
end
