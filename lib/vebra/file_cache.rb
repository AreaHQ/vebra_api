# frozen_string_literal: true

require 'yaml'

module Vebra
  class FileCache
    attr_reader :config, :tmp_dir

    def initialize(config, tmp_dir = defined?(Rails) ? Rails.root.join('tmp') : '.')
      @config = config
      @tmp_dir = tmp_dir
    end

    def get(key)
      value = cache_hash[key.to_s]
      return value unless value.nil? && block_given?

      value = yield
      set(key, value)
      value
    end

    def set(key, value)
      cache_hash[key.to_s] = value
      save_cache_to_file
    end

    def delete(key)
      cache_hash.delete(key.to_s)
      save_cache_to_file
    end

    private

    def save_cache_to_file
      File.open(file_path, 'w') do |f|
        f.write(cache_hash.to_yaml)
      end
    end

    def redis_key(key)
      "#{redis_key_prefix}-#{key}"
    end

    def cache_hash
      @cache_hash ||= File.exist?(file_path) ? (YAML.load_file(file_path) || {}) : {}
    end

    def file_path
      @file_path ||= "#{tmp_dir}/#{config.base_uri.gsub('/', '-')}-#{config.data_feed_id}.yml"
    end
  end
end
