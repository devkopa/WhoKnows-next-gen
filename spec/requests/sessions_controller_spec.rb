require 'rails_helper'

RSpec.describe 'SessionsController', type: :request do
  describe 'GET /login' do
    it 'renders login when not logged in' do
      get '/login'
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to root when logged in' do
      allow_any_instance_of(SessionsController).to receive(:session).and_return({ user_id: 1 })
      get '/login'
      expect(response).to redirect_to('/')
    end
  end

  describe 'GET /register' do
    it 'renders register when not logged in' do
      get '/register'
      expect(response).to have_http_status(:ok)
    end

    it 'redirects to root when logged in' do
      allow_any_instance_of(SessionsController).to receive(:session).and_return({ user_id: 1 })
      get '/register'
      expect(response).to redirect_to('/')
    end
  end
end
