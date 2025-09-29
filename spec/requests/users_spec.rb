require 'swagger_helper'

RSpec.describe 'Users API', type: :request do
  path '/users' do
    get 'Retrieves all users' do
      tags 'Users'
      produces 'application/json'

      response '200', 'users found' do
        run_test!
      end
    end

    post 'Creates a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          email: { type: :string },
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: [ 'username', 'email', 'password', 'password_confirmation' ]
      }

      response '201', 'user created' do
        let(:user) do
          {
            username: 'John Doe',
            email: 'john@example.com',
            password: 'password',
            password_confirmation: 'password'
          }
        end

        # Make sure to send JSON
        let(:'Content-Type') { 'application/json' }
        let(:body) { user.to_json }

        run_test!
      end
    end
  end

  path '/users/{id}' do
    get 'Retrieves a user' do
      tags 'Users'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'user found' do
        let(:id) { User.create(username: 'Jane', email: 'jane@example.com', password: 'password', password_confirmation: 'password').id }
        run_test!
      end

      response '404', 'user not found' do
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
