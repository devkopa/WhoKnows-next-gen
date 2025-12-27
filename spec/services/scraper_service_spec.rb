require 'rails_helper'

RSpec.describe ScraperService, type: :service do
  describe '.scrape' do
    let(:url) { 'http://example.com/test' }

    it 'builds a Faraday connection and returns parsed title and content on success' do
      conn_double = double('conn')
      builder_double = double('builder')
      html = '<html><head><title>My Title</title></head><body><p>Some content</p></body></html>'
      response_double = double('response', status: 200, body: html)

      expect(builder_double).to receive(:response).with(:raise_error)
      expect(builder_double).to receive(:adapter).with(Faraday.default_adapter)

      allow(Faraday).to receive(:new).and_yield(builder_double).and_return(conn_double)
      allow(conn_double).to receive(:get).with(url).and_return(response_double)

      # Ensure allowed_url? returns true for this test
      allow(ScraperService).to receive(:allowed_url?).with(url).and_return(true)

      result = ScraperService.scrape(url)

      expect(result).to be_a(Hash)
      expect(result[:url]).to eq(url)
      expect(result[:title]).to eq('My Title')
      expect(result[:content]).to include('Some content')
    end

    it 'returns nil for disallowed private IPs (allowed_url? false)' do
      bad_url = 'http://192.168.0.1/'
      allow(ScraperService).to receive(:allowed_url?).with(bad_url).and_return(false)
      expect(ScraperService.scrape(bad_url)).to be_nil
    end
  end

  describe '.allowed_url?' do
    it 'returns true when IPAddr.getaddr raises (non-resolvable host)' do
      url = 'http://nonexistent.example'
      orig_ipaddr = Object.const_get(:IPAddr)
      stub_const('IPAddr', Class.new do
        def self.getaddr(_)
          raise StandardError.new('no dns')
        end
      end)

      expect(ScraperService.send(:allowed_url?, url)).to be true
      stub_const('IPAddr', orig_ipaddr)
    end

    it 'returns false for private addresses' do
      url = 'http://127.0.0.1'
      # Replace IPAddr.getaddr to return an object that is private
      stub_const('IPAddr', Class.new do
        def self.getaddr(_)
          Object.new.tap do |o|
            def o.private?; true; end
            def o.loopback?; false; end
            def o.link_local?; false; end
            def o.multicast?; false; end
          end
        end
      end)

      expect(ScraperService.send(:allowed_url?, url)).to be false
    end
  end
end
require 'rails_helper'

RSpec.describe ScraperService do
  describe '.scrape' do
    let(:url) { 'http://example.com' }

    context 'when the request is successful' do
      let(:html) { '<html><head><title>Example Title</title></head><body>Example Body</body></html>' }
      let(:faraday_response) { instance_double(Faraday::Response, status: 200, body: html) }
      let(:conn) { instance_double(Faraday::Connection) }

      before do
        allow(Faraday).to receive(:new).and_return(conn)
        allow(conn).to receive(:get).with(url).and_return(faraday_response)
      end

      it 'returns parsed title and content' do
        result = described_class.scrape(url)
        expect(result[:url]).to eq(url)
        expect(result[:title]).to eq('Example Title')
        expect(result[:content]).to eq('Example Body')
      end

      it 'handles missing title and body gracefully' do
        empty_html = '<html><head></head><body></body></html>'
        empty_response = instance_double(Faraday::Response, status: 200, body: empty_html)
        allow(conn).to receive(:get).with(url).and_return(empty_response)

        result = described_class.scrape(url)
        expect(result[:title]).to eq('No title')
        expect(result[:content]).to eq('No content')
      end
    end

    context 'when the request fails' do
      let(:conn) { instance_double(Faraday::Connection) }

      before do
        allow(Faraday).to receive(:new).and_return(conn)
        allow(conn).to receive(:get).with(url).and_raise(Faraday::Error, 'boom')
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
      urls = [ 'http://a.test', 'http://b.test' ]
      first = { url: urls[0], title: 'A', content: 'Content A' }
      second = nil

      allow(described_class).to receive(:scrape).with(urls[0]).and_return(first)
      allow(described_class).to receive(:scrape).with(urls[1]).and_return(second)

      result = described_class.scrape_multiple(urls)
      expect(result).to eq([ first ])
    end
  end
end
