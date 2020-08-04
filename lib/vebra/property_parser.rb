# frozen_string_literal: true

module Vebra
  class PropertyParser
    MAPPINGS = YAML.load_file(File.join(__dir__, 'mappings.yml')).freeze

    def initialize(xml)
      @xml = xml
    end

    def call
      hash = xml.to_hash
    end
  end
end
