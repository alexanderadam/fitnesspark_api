# frozen_string_literal: true

RSpec.describe FitnessparkApi do
  subject { FitnessparkApi }

  describe '.stores' do
    it 'returns well formed JSON' do
      json = FitnessparkApi.stores
      expect(json).to be_a(Hash)
      expect(json['stores'].first['localized_slugs']['de']).to eq('activ-fitness-acacias')
    end
  end

  describe '.store' do
    it 'returns well formed JSON' do
      json = FitnessparkApi.store('gdps_vst-0154860')
      expect(json['id']).to eq('gdps_vst-0154860')
    end
  end

  describe '.visitors' do
    it 'returns well formed JSON' do
      json = FitnessparkApi.visitors(141)
      expect(json['centerId']).to eq(141)
    end
  end

  describe '.config' do
    it 'returns config data' do
      expect(FitnessparkApi.config.dig('stores', 'default_params', 'limit')).to eq('5000')
    end
  end

  describe '.center_volume_id' do
    it 'returns a center_volume_id by a slug' do
      expect(FitnessparkApi.center_volume_id('fitnesspark-stadelhofen')).to eq(141)
    end
  end

  describe '.api_key' do
    it 'returns a session key' do
      expect(FitnessparkApi.api_key).to eq('xabrutha3Hadrena')
    end
  end
end
