require 'rails_helper'

RSpec.describe ScraperService do
  describe '.scrape' do
    let(:url) { 'http://example.com' }

    context 'when the request is successful' do
      let(:html) { '<html><head><title>Example Title</title></head><body>Example Body</body></html>' }
      let(:response) { instance_double(HTTParty::Response, success?: true, body: html) }

      before do
        allow(HTTParty).to receive(:get).with(url).and_return(response)
      end

      it 'returns parsed title and content' do
        result = described_class.scrape(url)
        expect(result[:url]).to eq(url)
        expect(result[:title]).to eq('Example Title')
        expect(result[:content]).to eq('Example Body')
      end

      it 'handles missing title and body gracefully' do
        empty_html = '<html><head></head><body></body></html>'
        empty_response = instance_double(HTTParty::Response, success?: true, body: empty_html)
        allow(HTTParty).to receive(:get).with(url).and_return(empty_response)

        result = described_class.scrape(url)
        expect(result[:title]).to eq('No title')
        expect(result[:content]).to eq('No content')
      end
    end

    context 'when the request fails' do
      let(:response) { instance_double(HTTParty::Response, success?: false) }

      before do
        allow(HTTParty).to receive(:get).with(url).and_return(response)
      end

      it 'returns nil' do
        expect(described_class.scrape(url)).to be_nil
      end
    end

    context 'when an exception occurs' do
      before do
        allow(HTTParty).to receive(:get).with(url).and_raise(StandardError.new('boom'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error and returns nil' do
        expect(described_class.scrape(url)).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Scrape failed for #{Regexp.escape(url)}: boom/)
      end
    end
  end

  describe '.scrape_multiple' do
    it 'scrapes multiple urls and compacts nils' do
      urls = ['http://a.test', 'http://b.test']
      first = { url: urls[0], title: 'A', content: 'Content A' }
      second = nil

      allow(described_class).to receive(:scrape).with(urls[0]).and_return(first)
      allow(described_class).to receive(:scrape).with(urls[1]).and_return(second)

      result = described_class.scrape_multiple(urls)
      expect(result).to eq([first])
    end
  end
end
