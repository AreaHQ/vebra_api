# frozen_string_literal: true

module Vebra
  module API
    def branches_url
      config.uri + '/branch'
    end

    def branch_url
      branches_url + '/{branch_id}'
    end

    def properties_url
      branch_url + '/property'
    end

    def properties_since_url
      branch_url + '/property/{year}/{month}/{day}/{hour}/{minute}/{second}'
    end

    def property_url
      properties_url + '/{property_id}'
    end

    # Compiles a url string, interpolating the dynamic components
    def compile(url_string, config, interpolations = {})
      interpolations = config.to_h.merge(interpolations)
      url_string.gsub(/\{(\w+)\}/) do
        interpolations[Regexp.last_match(1).to_sym]
      end
    end

    # Performs the request to the Vebra API server
    def get(url, auth, retries = 0)
      debug_log "requesting #{url}"

      # build a Net::HTTP request object
      uri     = URI.parse(url)
      http    = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      http.use_ssl = true if uri.is_a?(URI::HTTPS)

      # add authorization header (either user/pass or token based)
      if (token = config.cache.get(:token))
        debug_log 'authorizing via token'
        request.basic_token(token)
      else
        debug_log 'authorizing via basic auth'
        request.basic_auth(config.username, config.password)
      end

      # make the request
      response = http.request(request)

      # monitor for 401, signalling that our token has expired
      if response.code.to_i == 401
        debug_log "encountered 401 Unauthorized (attempt ##{retries + 1})"
        # also monitor for multiple retries, in order to prevent
        # infinite retries
        if retries >= 3
          # not sure what to return here...
          raise '[Vebra]: failed to authenticate'
        end

        # retry with basic auth
        retries += 1
        config.cache.delete(:token)
        return get(url, auth, retries)
      else
        # extract & store the token for subsequent requests
        if response['token']
          debug_log "storing API token #{response['token']}"
          config.cache.set(:token, response['token'])
        end
      end

      # return parsed response object
      Response.new(response)
    end
  end
end
