# frozen_string_literal: true

module Vebra
  class Branch < Model
    # Retrieve the full set of attributes for this branch
    def get_branch
      @xml = client.call(url).parsed_response.css('branch').first
      @attributes.merge!(parse_xml_to_hash)
    end

    # Call the API method to retrieve a collection of properties for this branch,
    # and build a Vebra::Property object for each
    def get_properties
      xml = client.call("#{url}/property").parsed_response
      xml.css('properties property').map { |p| Vebra::Property.new(client, p, branch: self) }
    end

    # As above, but uses the API method to get only properties updated since a given date/time
    def get_properties_updated_since(datetime)
      year    = datetime.year
      month   = '%02d' % datetime.month
      day     = '%02d' % datetime.day
      hour    = '%02d' % datetime.hour
      minute  = '%02d' % datetime.min
      second  = '%02d' % datetime.sec
      base = client.compile(client.config.uri, client.config.to_h, {})
      xml = client.call("#{base}/property/#{year}/#{month}/#{day}/#{hour}/#{minute}/#{second}").parsed_response
      xml.css('propertieschanged property').map { |p| Vebra::Property.new(client, p, branch: self) }
    end

    def get_recently_updated_properties
      key = "properties_update_datetime-#{branchid}"
      datetime = Time.at(client.config.cache.get(key) do
        Time.new(1990).to_i
      end.to_i)
      result = get_properties_updated_since(datetime)
      client.config.cache.set(key, Time.now.to_i)
      result
    end
  end
end
