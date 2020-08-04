# frozen_string_literal: true

require 'active_support/xml_mini/nokogiri'
require 'active_support/core_ext/hash/except'

module Vebra
  class Model
    MAPPINGS = YAML.load_file(File.join(__dir__, 'mappings.yml')).freeze

    attr_reader :client, :xml, :relations, :attributes

    def initialize(client = Vebra.client, xml = nil, relations = {})
      @client = client
      @xml = xml
      @relations = relations
      @attributes = parse_xml_to_hash
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s.chars.last == '='
        attributes[method_name[0...-1].to_sym] = args.first
      else
        attributes.key?(method_name.to_sym) ? attributes[method_name.to_sym] : super
      end
    end

    def respond_to_missing?(method_name)
      method_name.to_s.chars.last == '=' || attributes.key?(method_name.to_sym)
    end

    private

    def parse_xml_to_hash
      return {} if xml.nil?

      hash = Nori.new.parse(xml.to_xml).first.last.deep_symbolize_keys!

      cast_hash(hash)
      apply_mappings(hash)
    end

    def cast_hash(hash)
      hash.each do |key, value|
        case value
        when String
          hash[key] = cast_value(value)
        when Array
          hash[key].map! { |element| cast_value(element) }
        when Hash
          hash[key] = cast_hash(value)
        end
      end
    end

    def cast_value(value)
      return value unless is_a?(String)

      number = Integer(value, exception: false) || Float(value, exception: false)

      return number if number
      return if value.gsub(/^\s+|\s+$/, '') == '' || value == '(Not Specified)'
      return Time.parse(value) if /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}\.\d{2})?$/ =~ value

      value
    end

    def apply_mappings(hash, previous_keys = [])
      hash.each do |key, value|
        keys = previous_keys + [key]
        case value
        when Array
          hash[key].map! { |element| element.is_a?(Hash) ? apply_mappings(element, keys) : map_value(element, keys) }
        when Hash
          hash[key] = apply_mappings(value, keys)
        else
          hash[key] = map_value(value, keys)
        end
      end
    end

    def map_value(value, keys)
      key = Array(keys).map(&:to_s).join('_')

      return value unless MAPPINGS.key?(key)

      MAPPINGS[key][value.to_i]
    end
  end
end
