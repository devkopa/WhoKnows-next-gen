require 'rails_helper'
require_relative '../../../lib/services/wiki_crawler_service'

RSpec.describe Services::WikiCrawlerService do
  describe '.scrape_for' do
    let(:query) { 'Ruby' }

    before do
      allow(Rails.logger).to receive(:debug)
      allow(Rails.logger).to receive(:warn)
    end

    it 'returns [] for blank query' do
      expect(described_class.scrape_for('   ')).to eq([])
    end

    it 'logs search response and returns extracted pages' do
      search_json = {
        'query' => {
          'search' => [{ 'title' => 'Ruby (programming language)' }]
        }
      }

      extracts_json = {
        'query' => {
          'pages' => {
            '123' => {
              'title' => 'Ruby (programming language)',
              'extract' => 'Ruby is a programming language.'
            }
          }
        }
      }

      allow(described_class).to receive(:get_json).with(Services::WikiCrawlerService::API_ENDPOINT, hash_including(list: 'search')).and_return(search_json)
      allow(described_class).to receive(:get_json).with(Services::WikiCrawlerService::API_ENDPOINT, hash_including(prop: 'extracts')).and_return(extracts_json)

      result = described_class.scrape_for(query, limit: 1)

      expect(Rails.logger).to have_received(:debug).with(/WikiCrawlerService search response for 'Ruby':/)
      expect(result.first[:title]).to eq('Ruby (programming language)')
      expect(result.first[:url]).to match(%r{https://en.wikipedia.org/wiki/Ruby})
      expect(result.first[:content]).to include('Ruby is a programming language')
    end

    it 'falls back to opensearch and logs when no query.search present' do
      search_json = { 'query' => {} }
      opensearch_json = ['Ruby', ['Ruby (programming language)']]
      extracts_json = {
        'query' => {
          'pages' => {
            '123' => { 'title' => 'Ruby (programming language)', 'extract' => 'Desc' }
          }
        }
      }

      allow(described_class).to receive(:get_json).with(Services::WikiCrawlerService::API_ENDPOINT, hash_including(list: 'search')).and_return(search_json)
      allow(described_class).to receive(:get_json).with(Services::WikiCrawlerService::API_ENDPOINT, hash_including(action: 'opensearch')).and_return(opensearch_json)
      allow(described_class).to receive(:get_json).with(Services::WikiCrawlerService::API_ENDPOINT, hash_including(prop: 'extracts')).and_return(extracts_json)

      result = described_class.scrape_for(query, limit: 1)
      expect(Rails.logger).to have_received(:debug).with(/WikiCrawlerService opensearch response for 'Ruby':/)
      expect(result.first[:title]).to eq('Ruby (programming language)')
    end

    it 'rescues errors and returns [] while logging warn' do
      allow(described_class).to receive(:get_json).and_raise(StandardError.new('network error'))
      result = described_class.scrape_for(query)
      expect(result).to eq([])
      expect(Rails.logger).to have_received(:warn).with(/WikiCrawlerService error for 'Ruby': network error/)
    end
  end
end
