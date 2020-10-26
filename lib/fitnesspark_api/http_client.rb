# frozen_string_literal: true

require 'net/http'
require 'oj'
require 'oga'

module FitnessparkApi
  module HttpClient
    module_function

    def get_json(uri, headers: {})
      response = get(uri, headers: headers)

      Oj.load(response.body)
    end

    def get_html(uri, headers: {})
      response = get(uri, headers: headers)

      Oga.parse_html(response.body.force_encoding('UTF-8'))
    end

    def get_center_volume_id(url)
      html = get_html(url)
      html.css('.centerVolume').first.attribute('centerId').value.to_i
    end

    def get(uri, headers: {}, max_redirect_count: 10)
      uri = URI(uri) if uri.is_a?(String)

      request = Net::HTTP::Get.new(uri)
      headers.merge!('User-Agent' => user_agent, 'Origin' => 'https://www.migros-fitness.ch')
      headers.each { |name, value| request[name] = value }

      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      response = http.request(request)
      if response.is_a?(Net::HTTPRedirection) && response['location'] && max_redirect_count.positive?
        return get(response['location'], headers: headers, max_redirect_count: max_redirect_count - 1)
      end

      ensure_successful_response(response)
      response
    end

    def user_agent
      format(FitnessparkApi.config['user_agent'], version: VERSION)
    end

    def ensure_successful_response(response)
      return if response.code == '200'

      if response.body.to_s.strip.start_with?('{')
        error_json = Oj.load(response.body)
        if error_json.key?('error')
          msg = error_json['error']
          msg << ": #{error_json['message']}" if error_json.key?('message')
        else
          msg = error_json.to_s
        end
      else
        msg = "Unsuccessful response #{response.code}"
      end

      raise ResponseError, msg
    end

    def api_key
      return @api_key if @api_key

      html = get_html('https://www.migros-fitness.ch/karte')
      json = Oj.load(html.css('html').first.attribute('data-setup').value.gsub("'", '"'))
      @api_key = json['sessionKey']
    end
  end
end
