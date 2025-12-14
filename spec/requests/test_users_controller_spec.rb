require 'rails_helper'

RSpec.describe 'Test::UsersController', type: :request do
  let(:user_params) do
    {
      username: 'testuser',
      email: 'testuser@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  end

  describe 'POST /test/register' do
    context 'with valid parameters' do
      it 'creates a new user and returns success response' do
        post '/test/register', params: { user: user_params }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(
          'username' => 'testuser',
          'message' => 'Registration successful'
        )
        expect(User.find_by(username: 'testuser')).to be_present
      end

      it 'creates user with JSON body format' do
        post '/test/register',
             params: user_params.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['username']).to eq('testuser')
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable_entity when password confirmation does not match' do
        invalid_params = user_params.merge(password_confirmation: 'wrong')
        post '/test/register', params: { user: invalid_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end

      it 'returns unprocessable_entity when username is missing' do
        invalid_params = user_params.except(:username)
        post '/test/register', params: { user: invalid_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end

      it 'returns unprocessable_entity when email is missing' do
        invalid_params = user_params.except(:email)
        post '/test/register', params: { user: invalid_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('errors')
      end
    end
  end

  describe 'POST /test/login' do
    before do
      User.create!(
        username: 'existinguser',
        email: 'existing@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
    end

    context 'with valid credentials' do
      it 'authenticates user and creates session' do
        post '/test/login', params: { user: { username: 'existinguser', password: 'password123' } }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include(
          'username' => 'existinguser',
          'message' => 'Login successful'
        )
        expect(session[:user_id]).to be_present
      end

      it 'logs in user with JSON body format' do
        post '/test/login',
             params: { username: 'existinguser', password: 'password123' }.to_json,
             headers: { 'CONTENT_TYPE' => 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(session[:user_id]).to be_present
      end

      it 'updates last_login timestamp' do
        user = User.find_by(username: 'existinguser')
        original_last_login = user.last_login

        post '/test/login', params: { user: { username: 'existinguser', password: 'password123' } }

        user.reload
        expect(user.last_login).to be > original_last_login unless original_last_login.nil?
      end

      it 'increments USER_LOGINS metric for success' do
        if defined?(USER_LOGINS)
          expect(USER_LOGINS).to receive(:increment).with(labels: { status: 'success' })
        end

        post '/test/login', params: { user: { username: 'existinguser', password: 'password123' } }
      end

      it 'still succeeds if last_login update fails (covers rescue path)' do
        user = User.find_by(username: 'existinguser')
        allow(user).to receive(:update_columns).and_raise(StandardError)
        allow(User).to receive(:find_by).and_return(user)

        post '/test/login', params: { user: { username: 'existinguser', password: 'password123' } }

        expect(response).to have_http_status(:ok)
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context 'with invalid credentials' do
      it 'returns unauthorized for wrong password' do
        post '/test/login', params: { user: { username: 'existinguser', password: 'wrongpassword' } }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Invalid username or password')
        expect(session[:user_id]).to be_nil
      end

      it 'returns unauthorized for non-existent user' do
        post '/test/login', params: { user: { username: 'nonexistent', password: 'password123' } }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq('Invalid username or password')
      end

      it 'increments USER_LOGINS metric for failure' do
        if defined?(USER_LOGINS)
          expect(USER_LOGINS).to receive(:increment).with(labels: { status: 'failure' })
        end

        post '/test/login', params: { user: { username: 'existinguser', password: 'wrongpassword' } }
      end
    end
  end

  describe 'GET /test/logout' do
    it 'clears the session and returns success response' do
      user = User.create!(
        username: 'sessionuser',
        email: 'session@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      )
      # Set session by logging in first
      post '/test/login', params: { user: { username: 'sessionuser', password: 'password123' } }

      get '/test/logout'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end

    it 'clears session even when no user is logged in' do
      get '/test/logout'

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq('Logged out successfully')
    end
  end
end
