# frozen_string_literal: true

require 'yaml'
require_relative 'fitnesspark_api/version'
require_relative 'fitnesspark_api/http_client'

module FitnessparkApi
  ResponseError = Class.new(IOError)
  STORES_URL = 'https://web-api.migros.ch/widgets/stores'
  VISITORS_URL = 'https://blfa-api.migros.ch/fp/api/center/%<center_id>s/currentuser'

  module_function

  def stores(get_params = nil)
    get_params ||= config.dig('stores', 'default_params')
    get_params['key'] ||= api_key

    uri = URI(STORES_URL)
    uri.query = URI.encode_www_form(get_params)
    HttpClient.get_json(uri)
  end

  def store(center_id)
    get_params = { 'key' => api_key }
    uri = URI(File.join(STORES_URL, center_id))
    uri.query = URI.encode_www_form(get_params)
    HttpClient.get_json(uri)
  end

  def visitors(center_id)
    center_id = center_volume_id(center_id) if center_id.is_a?(String) && !center_id.match(/\A\d+\z/)
    uri = URI(format(VISITORS_URL, center_id: center_id))
    HttpClient.get_json(uri)
  end

  def config
    YAML.load_file(File.join(File.dirname(__FILE__), '..', 'data', 'config.yml'))
  end

  def center_volume_id(slug)
    base_data = base_data_by_name(slug)
    detail_data = store(base_data['id'])
    markets = detail_data['markets']
    raise(ArgumentError, "Found more than one center for slug #{slug}") unless markets.one?

    HttpClient.get_center_volume_id(markets.first['weblink']['url'])
  end

  def base_data_by_name(slug)
    all_base_data = stores
    result = all_base_data['stores'].find do |store_hash|
      store_hash['name'] == slug ||
        store_hash['id'] == slug ||
        store_hash['slug'] == slug ||
        store_hash.dig('localized_slugs', 'de') == slug ||
        store_hash.dig('localized_slugs', 'it') == slug ||
        store_hash.dig('localized_slugs', 'fr') == slug ||
        store_hash['additional_slugs'].include?(slug) ||
        store_hash['additional_ids'].include?(slug)
    end

    return result if result

    all_slugs = stores['stores'].map { |s| s['slug'] }.uniq.sort
    raise(ArgumentError, "Unable to find #{slug.inspect}. Did you mean one of these: #{all_slugs.inspect}")
  end

  def api_key
    ENV['FITNESSPARK_SESSION_KEY'] || HttpClient.api_key
  end
end
