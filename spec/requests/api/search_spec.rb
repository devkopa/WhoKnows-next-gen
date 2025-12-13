require 'rails_helper'

RSpec.describe 'Api::SearchController', type: :request do
  describe 'GET /api/search' do
    let!(:page_with_url) do
      Page.create!(title: 'Hello World', content: 'a' * 300, url: '/custom/hello')
    end

    let!(:page_without_url) do
      Page.create!(title: 'Ruby on Rails', content: 'Short content', url: nil)
    end

    context 'JSON format' do
      it 'returns results with truncated content and custom url when query present' do
        get '/api/search.json', params: { q: 'Hello' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).to be_an(Array)
        titles = json['data'].map { |r| r['title'] }
        expect(titles).to include('Hello World')

        result = json['data'].find { |r| r['title'] == 'Hello World' }
        expect(result['url']).to eq('/custom/hello')
        expect(result['content'].length).to be <= 150
        expect(json['count']).to eq(json['data'].size)
      end

      it 'falls back to BASE_PAGE_URL when url missing' do
        get '/api/search.json', params: { q: 'Rails' }

        json = JSON.parse(response.body)
        rails_result = json['data'].find { |r| r['title'] == 'Ruby on Rails' }
        expect(rails_result).to be_present
        # Fallback uses /pages/:primary_key (title in this schema)
        expect(rails_result['url']).to match(%r{^/pages/.+})
      end

      it 'limits results to MAX_RESULTS when no query' do
        # Create extra pages to exceed the limit
        120.times do |i|
          Page.create!(title: "Extra #{i}", content: 'c')
        end

        get '/api/search.json'
        json = JSON.parse(response.body)
        expect(json['data'].size).to be <= Api::SearchController::MAX_RESULTS
      end
    end

    context 'HTML format' do
      it 'renders the search template' do
        get '/api/search', params: { q: 'Hello' }
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq('text/html')
      end
    end

    context 'logging and metrics' do
      it 'logs search queries without raising' do
        expect { get '/api/search.json', params: { q: 'Hello' } }.not_to raise_error
      end

      it 'handles metric increment failures gracefully' do
        stub_const('Api::SearchController::SEARCH_REQUESTS', double('metric'))
        allow(Api::SearchController::SEARCH_REQUESTS).to receive(:increment).and_raise(StandardError.new('boom'))

        get '/api/search.json', params: { q: 'Hello' }
        expect(response).to have_http_status(:ok)
      end

      it 'rescues failures inside log_search' do
        allow(SearchLog).to receive(:create).and_raise(StandardError.new('log fail'))
        expect(Rails.logger).to receive(:error).with(/Failed to log search:/)

        get '/api/search.json', params: { q: 'Hello' }
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
