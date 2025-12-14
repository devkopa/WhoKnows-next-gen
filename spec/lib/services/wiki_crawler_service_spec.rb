require 'rails_helper'

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
          'search' => [ { 'title' => 'Ruby (programming language)' } ]
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

    it 'returns [] when titles list is empty' do
      search_json = { 'query' => { 'search' => [] } }
      allow(described_class).to receive(:get_json).and_return(search_json)

      results = described_class.scrape_for(query, limit: 1)
      expect(results).to eq([])
    end

    it 'falls back to opensearch and logs when no query.search present' do
      search_json = { 'query' => {} }
      opensearch_json = [ 'Ruby', [ 'Ruby (programming language)' ] ]
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

  describe '.get_json' do
    it 'returns parsed JSON on success' do
      endpoint = Services::WikiCrawlerService::API_ENDPOINT
      params = { action: 'query', format: 'json' }

      fake_http = instance_double(Net::HTTP)
      fake_resp = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(fake_resp).to receive(:body).and_return('{"result":"success"}')

      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)
      allow(fake_http).to receive(:request).and_return(fake_resp)

      result = described_class.get_json(endpoint, params)
      expect(result).to eq({ 'result' => 'success' })
    end

    it 'returns nil on non-success HTTP response' do
      endpoint = Services::WikiCrawlerService::API_ENDPOINT
      params = { action: 'query', format: 'json' }

      fake_http = instance_double(Net::HTTP)
      fake_resp = Net::HTTPBadRequest.new('1.1', '400', 'Bad Request')
      allow(Net::HTTP).to receive(:new).and_return(fake_http)
      allow(fake_http).to receive(:use_ssl=)
      allow(fake_http).to receive(:open_timeout=)
      allow(fake_http).to receive(:read_timeout=)
      allow(fake_http).to receive(:request).and_return(fake_resp)

      result = described_class.get_json(endpoint, params)
      expect(result).to be_nil
    end
  end

  describe '.log_debug (private)' do
    it 'calls Rails.logger.debug when Rails is available' do
      message = 'Test debug message'
      allow(Rails.logger).to receive(:debug)
      described_class.send(:log_debug, message)
      expect(Rails.logger).to have_received(:debug).with(message)
    end

    it 'calls puts when Rails is not available' do
      message = 'Test debug without rails'
      # Temporarily hide Rails
      original_rails = ::Rails
      Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)

      begin
        expect { described_class.send(:log_debug, message) }.to output(/#{Regexp.escape(message)}/).to_stdout
      ensure
        # Restore Rails
        Object.const_set(:Rails, original_rails)
      end
    end
  end

  describe '.log_warn (private)' do
    it 'calls Rails.logger.warn when Rails is available' do
      message = 'Test warn message'
      allow(Rails.logger).to receive(:warn)
      described_class.send(:log_warn, message)
      expect(Rails.logger).to have_received(:warn).with(message)
    end

    it 'calls warn when Rails is not available' do
      message = 'Test warn without rails'
      # Temporarily hide Rails
      original_rails = ::Rails
      Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)

      begin
        expect { described_class.send(:log_warn, message) }.to output(/#{Regexp.escape(message)}/).to_stderr
      ensure
        # Restore Rails
        Object.const_set(:Rails, original_rails)
      end
    end
  end
end
