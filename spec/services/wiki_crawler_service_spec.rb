# spec/services/wiki_crawler_service_spec.rb
require 'rails_helper'
require 'services/wiki_crawler_service'

RSpec.describe Services::WikiCrawlerService, type: :service do
  let(:api_endpoint) { "https://en.wikipedia.org/w/api.php" }
  let(:user_agent) { "WhoKnowsWikiCrawler/1.0 (https://example.com)" }

  describe '.scrape_for' do
    context 'with empty query' do
      it 'returns empty array' do
        result = described_class.scrape_for('')
        expect(result).to eq([])
      end

      it 'returns empty array for nil query' do
        result = described_class.scrape_for(nil)
        expect(result).to eq([])
      end

      it 'returns empty array for whitespace-only query' do
        result = described_class.scrape_for('   ')
        expect(result).to eq([])
      end
    end

    context 'with valid query and search list success' do
      it 'returns formatted results from search list' do
        search_response = {
          "query" => {
            "search" => [
              { "title" => "Ruby programming language" },
              { "title" => "Ruby (gem)" }
            ]
          }
        }

        extract_response = {
          "query" => {
            "pages" => {
              "123" => { "title" => "Ruby programming language", "extract" => "Ruby is a dynamic language." },
              "456" => { "title" => "Ruby (gem)", "extract" => "A precious stone." }
            }
          }
        }

        allow(described_class).to receive(:get_json)
          .with(api_endpoint, hash_including(list: "search"))
          .and_return(search_response)
        allow(described_class).to receive(:get_json)
          .with(api_endpoint, hash_including(prop: "extracts"))
          .and_return(extract_response)

        result = described_class.scrape_for('Ruby', limit: 2)

        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result[0]).to include(title: 'Ruby programming language', content: 'Ruby is a dynamic language.')
        expect(result[0]).to have_key(:url)
        expect(result[0][:url]).to include('en.wikipedia.org/wiki/Ruby')
      end
    end

    context 'with search list returning nil' do
      it 'falls back to opensearch' do
        search_response = nil

        opensearch_response = [
          'Python',
          ['Python (programming language)', 'Python (snake)'],
          ['Desc1', 'Desc2'],
          ['url1', 'url2']
        ]

        extract_response = {
          "query" => {
            "pages" => {
              "789" => { "title" => "Python (programming language)", "extract" => "Python is a snake and language." }
            }
          }
        }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          if call_count == 1
            search_response
          elsif call_count == 2
            opensearch_response
          else
            extract_response
          end
        end

        result = described_class.scrape_for('Python', limit: 2)

        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result[0][:title]).to eq('Python (programming language)')
      end
    end

    context 'with search list returning empty query node' do
      it 'falls back to opensearch' do
        search_response = { "query" => {} }

        opensearch_response = [
          'Java',
          ['Java (programming language)'],
          ['Desc'],
          ['url']
        ]

        extract_response = {
          "query" => {
            "pages" => {
              "321" => { "title" => "Java (programming language)", "extract" => "Java is an OOP language." }
            }
          }
        }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          case call_count
          when 1 then search_response
          when 2 then opensearch_response
          else extract_response
          end
        end

        result = described_class.scrape_for('Java', limit: 1)

        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result[0][:title]).to eq('Java (programming language)')
      end
    end

    context 'with opensearch returning nil' do
      it 'falls back to empty array for titles' do
        search_response = { "query" => { "search" => nil } }
        opensearch_response = nil

        extract_response = { "query" => { "pages" => {} } }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          case call_count
          when 1 then search_response
          when 2 then opensearch_response
          else extract_response
          end
        end

        result = described_class.scrape_for('unknown', limit: 1)

        expect(result).to eq([])
      end
    end

    context 'with opensearch returning array with empty titles' do
      it 'returns empty array' do
        search_response = { "query" => { "search" => [] } }
        opensearch_response = ['term', [], [], []]

        extract_response = { "query" => { "pages" => {} } }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          case call_count
          when 1 then search_response
          when 2 then opensearch_response
          else extract_response
          end
        end

        result = described_class.scrape_for('nonexistent', limit: 1)

        expect(result).to eq([])
      end
    end

    context 'with extract pages nil' do
      it 'treats as empty hash' do
        search_response = {
          "query" => {
            "search" => [{ "title" => "Test" }]
          }
        }

        extract_response = { "query" => nil }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          case call_count
          when 1 then search_response
          else extract_response
          end
        end

        result = described_class.scrape_for('Test', limit: 1)

        expect(result).to eq([])
      end
    end

    context 'with missing extract content' do
      it 'uses empty string for content' do
        search_response = {
          "query" => {
            "search" => [{ "title" => "NoContent" }]
          }
        }

        extract_response = {
          "query" => {
            "pages" => {
              "999" => { "title" => "NoContent" }
            }
          }
        }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          case call_count
          when 1 then search_response
          else extract_response
          end
        end

        result = described_class.scrape_for('NoContent', limit: 1)

        expect(result).to be_an(Array)
        expect(result[0][:content]).to eq('')
      end
    end

    context 'when exception is raised' do
      it 'logs warning and returns empty array' do
        allow(described_class).to receive(:get_json).and_raise(StandardError.new('Network error'))

        expect(Rails.logger).to receive(:warn).with(/WikiCrawlerService error for 'Error'/)

        result = described_class.scrape_for('Error', limit: 1)

        expect(result).to eq([])
      end
    end

    context 'with URL encoding for spaces' do
      it 'encodes spaces in title as underscores' do
        search_response = {
          "query" => {
            "search" => [{ "title" => "Programming Language" }]
          }
        }

        extract_response = {
          "query" => {
            "pages" => {
              "111" => { "title" => "Programming Language", "extract" => "A language for coding." }
            }
          }
        }

        call_count = 0
        allow(described_class).to receive(:get_json) do |endpoint, params|
          call_count += 1
          case call_count
          when 1 then search_response
          else extract_response
          end
        end

        result = described_class.scrape_for('Programming Language', limit: 1)

        expect(result[0][:url]).to include('Programming_Language')
      end
    end
  end

  describe '.get_json' do
    it 'returns nil when response is not a success' do
      response_double = double('Response')
      allow(response_double).to receive(:is_a?).with(Net::HTTPSuccess).and_return(false)

      http_double = double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(http_double).to receive(:open_timeout=)
      allow(http_double).to receive(:read_timeout=)
      allow(http_double).to receive(:request).and_return(response_double)

      result = described_class.get_json(api_endpoint, {})

      expect(result).to be_nil
    end

    it 'configures HTTP timeouts' do
      response_double = double(Net::HTTPSuccess, body: {}.to_json)
      http_double = double(Net::HTTP)

      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(http_double).to receive(:open_timeout=)
      allow(http_double).to receive(:read_timeout=)
      allow(http_double).to receive(:request).and_return(response_double)

      described_class.get_json(api_endpoint, {})

      expect(http_double).to have_received(:open_timeout=).with(5)
      expect(http_double).to have_received(:read_timeout=).with(10)
    end

    it 'uses SSL for https endpoints' do
      response_double = double(Net::HTTPSuccess, body: {}.to_json)
      http_double = double(Net::HTTP)

      allow(Net::HTTP).to receive(:new).and_return(http_double)
      allow(http_double).to receive(:use_ssl=)
      allow(http_double).to receive(:open_timeout=)
      allow(http_double).to receive(:read_timeout=)
      allow(http_double).to receive(:request).and_return(response_double)

      described_class.get_json('https://en.wikipedia.org/w/api.php', {})

      expect(http_double).to have_received(:use_ssl=).with(true)
    end
  end
end
