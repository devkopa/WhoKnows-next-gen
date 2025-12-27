require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'ensure_timestamps' do
    it 'sets created_at and updated_at on create when attributes missing' do
      user = User.new(username: 'tester', email: 't@example.com', password: 'password123')

      # Simulate a model that does not respond to created_at/updated_at (edge case)
      allow(user).to receive(:respond_to?).and_wrap_original do |m, *args|
        if args.first == :created_at || args.first == :updated_at
          false
        else
          m.call(*args)
        end
      end

      expect { user.send(:ensure_timestamps) }.not_to raise_error
      expect(user.created_at).to be_present
      expect(user.updated_at).to be_present
    end

    it 'does not override existing timestamps' do
      now = 2.days.ago
      user = User.new(username: 'tester', email: 't2@example.com', password: 'password123')

      # Simulate existing timestamps by stubbing respond_to? to false and pre-setting ivars
      allow(user).to receive(:respond_to?).and_wrap_original do |m, *args|
        if args.first == :created_at || args.first == :updated_at
          false
        else
          m.call(*args)
        end
      end

      # First call sets them
      user.send(:ensure_timestamps)
      created = user.created_at
      updated = user.updated_at

      # Second call should not override existing values - simulate time moving forward
      later = created + 1.hour
      allow(Time).to receive(:current).and_return(later)
      user.send(:ensure_timestamps)

      expect(user.created_at).to eq(created)
      expect(user.updated_at).to eq(updated)
    end
  end
end
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "validates presence of username" do
      user = User.new(email: 'test@example.com', password: 'password123')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it "validates uniqueness of username" do
      User.create!(username: 'testuser', email: 'test1@example.com', password: 'password123')
      duplicate_user = User.new(username: 'testuser', email: 'test2@example.com', password: 'password123')

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:username]).to include("has already been taken")
    end

    it "requires a password" do
      user = User.new(username: 'testuser', email: 'test@example.com')
      expect(user).not_to be_valid
    end
  end

  describe "password authentication" do
    let(:user) { User.create!(username: 'testuser', email: 'test@example.com', password: 'password123') }

    it "authenticates with correct password" do
      expect(user.authenticate('password123')).to eq(user)
    end

    it "fails authentication with incorrect password" do
      expect(user.authenticate('wrongpassword')).to be false
    end
  end

  describe "callbacks" do
    it "sets timestamps on creation" do
      user = User.create!(username: 'testuser', email: 'test@example.com', password: 'password123')

      expect(user.created_at).not_to be_nil
      expect(user.updated_at).not_to be_nil
    end
  end
end
