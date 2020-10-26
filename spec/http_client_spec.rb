# frozen_string_literal: true

RSpec.describe FitnessparkApi::HttpClient do
  subject { FitnessparkApi::HttpClient }

  describe '.user_agent' do
    it 'starts with FitnessparkApi' do
      expect(FitnessparkApi::HttpClient.user_agent).to start_with('FitnessparkApi ')
    end
  end
end
