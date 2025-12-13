require 'rails_helper'

RSpec.describe 'HealthController', type: :request do
  describe 'GET /health' do
    it 'returns ok with timestamp and version' do
      allow(Rails.application.config).to receive(:version).and_return('9.9.9')
      get '/health'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['status']).to eq('ok')
      expect(body['version']).to eq('9.9.9')
      expect(body['timestamp']).to be_a(String)
    end
  end

  describe 'GET /health/ready' do
    context 'when database is reachable' do
      it 'returns ready status' do
        connection = double('connection')
        allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
        allow(connection).to receive(:execute).with('SELECT 1').and_return([[1]])

        get '/health/ready'
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['status']).to eq('ready')
        expect(body['checks']['database']['status']).to eq('ok')
      end
    end

    context 'when database is NOT reachable' do
      it 'returns not_ready with service_unavailable' do
        connection = double('connection')
        allow(ActiveRecord::Base).to receive(:connection).and_return(connection)
        allow(connection).to receive(:execute).with('SELECT 1').and_raise(StandardError.new('boom'))

        get '/health/ready'
        expect(response).to have_http_status(:service_unavailable)
        body = JSON.parse(response.body)
        expect(body['status']).to eq('not_ready')
        expect(body['checks']['database']['status']).to eq('error')
        expect(body['checks']['database']['message']).to match(/Database connection failed/)
      end
    end
  end

  describe 'GET /health/live' do
    it 'returns alive with uptime' do
      allow(Rails.application.config).to receive(:boot_time).and_return(Time.current - 123)
      get '/health/live'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['status']).to eq('alive')
      expect(body['uptime']).to be_a(Numeric)
      expect(body['uptime']).to be >= 120
    end

    it 'handles missing boot_time gracefully' do
      allow(Rails.application.config).to receive(:boot_time).and_raise(StandardError)
      get '/health/live'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['uptime']).to eq(0)
    end
  end

  describe 'GET /health/metrics' do
    before do
      allow(User).to receive(:count).and_return(5)
      allow(User).to receive(:where).and_return(double('rel', count: 2))

      allow(SearchLog).to receive(:count).and_return(7)
      allow(SearchLog).to receive(:where).and_return(double('rel', count: 3))

      allow(WeatherSearch).to receive(:count).and_return(4)
      allow(WeatherSearch).to receive(:where).and_return(double('rel', count: 1))

      allow(Page).to receive(:count).and_return(10)
    end

    it 'returns metrics summary when successful' do
      get '/health/metrics'
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['status']).to eq('ok')
      expect(body['metrics']['users']['total']).to eq(5)
      expect(body['metrics']['users']['recent_24h']).to eq(2)
      expect(body['metrics']['searches']['total']).to eq(7)
      expect(body['metrics']['weather_searches']['recent_24h']).to eq(1)
      expect(body['metrics']['pages']['total']).to eq(10)
    end

    it 'handles exceptions and returns error' do
      allow(User).to receive(:count).and_raise(StandardError.new('bad'))
      get '/health/metrics'
      expect(response).to have_http_status(:internal_server_error)
      body = JSON.parse(response.body)
      expect(body['status']).to eq('error')
      expect(body['message']).to be_a(String)
    end
  end
end
