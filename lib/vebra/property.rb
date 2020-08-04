# frozen_string_literal: true

module Vebra
  class Property < Model
    # property = Vebra::Property.new(nokogiri_xml_object, vebra_branch_object)

    def branch
      relations[:branch]
    end

    # Retrieve the full set of attributes for this branch
    def get_property
      @xml = client.call(url).parsed_response.css('property').first
      @attributes.merge!(parse_xml_to_hash)
    end

    def group
      @group ||= [2, 118].include?(attributes[:@database].to_i) ? 'lettings' : 'sales'
    end

    def web_status
      attributes[:web_status][group]
    end

    def published
      attributes[:web_status]['published']
    end
  end
end
