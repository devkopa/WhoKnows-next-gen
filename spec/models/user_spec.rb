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
