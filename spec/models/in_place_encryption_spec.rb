require 'rails_helper'

RSpec.describe InPlaceEncryption, type: :model do
  before(:all) do
    @old_secret_key_base = ENV.fetch('SECRET_KEY_BASE', nil)
    ENV['SECRET_KEY_BASE'] = ENV.fetch('SECRET_KEY_BASE') { 'test-secret-key-base' }
    ActiveRecord::Base.connection.create_table :in_place_tests, force: true do |t|
      t.text :secret_col
    end

    class ::InPlaceTest < ApplicationRecord
      self.table_name = 'in_place_tests'
      include InPlaceEncryption
      in_place_encrypts :secret_col
    end
  end

  after(:all) do
    Object.send(:remove_const, :InPlaceTest) if defined?(InPlaceTest)
    ActiveRecord::Base.connection.drop_table :in_place_tests, if_exists: true
    if @old_secret_key_base.nil?
      ENV.delete('SECRET_KEY_BASE')
    else
      ENV['SECRET_KEY_BASE'] = @old_secret_key_base
    end
  end

  it 'returns nil when underlying column is nil' do
    rec = InPlaceTest.new
    expect(rec.read_attribute(:secret_col)).to be_nil
    expect(rec.secret_col).to be_nil
  end

  it 'computes a stable HMAC for the same input' do
    rec1 = InPlaceTest.new
    rec1.secret_col = '90.102.94.230'
    rec2 = InPlaceTest.new
    rec2.secret_col = '90.102.94.230'
    expect(rec1.read_attribute(:secret_col)).to eq(rec2.read_attribute(:secret_col))
    expect(rec1.read_attribute(:secret_col)).not_to eq('90.102.94.230')
  end
  it 'writes nil when setter given nil' do
    rec = InPlaceTest.new
    rec.secret_col = nil
    expect(rec.read_attribute(:secret_col)).to be_nil
  end
end
