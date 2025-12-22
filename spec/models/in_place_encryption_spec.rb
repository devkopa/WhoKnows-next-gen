require 'rails_helper'

RSpec.describe InPlaceEncryption, type: :model do
  before(:all) do
    @old_secret_key_base = ENV['SECRET_KEY_BASE']
    ENV['SECRET_KEY_BASE'] = 'test-secret-key-base'
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
    ENV['SECRET_KEY_BASE'] = @old_secret_key_base
  end

  it 'returns nil when underlying column is nil' do
    rec = InPlaceTest.new
    expect(rec.read_attribute(:secret_col)).to be_nil
    expect(rec.secret_col).to be_nil
  end

  it 'encrypts on write and decrypts on read' do
    rec = InPlaceTest.new
    rec.secret_col = 'my-ip'
    # underlying stored value should not equal plaintext
    stored = rec.read_attribute(:secret_col)
    expect(stored).to be_a(String)
    expect(stored).not_to eq('my-ip')
    # getter returns plaintext
    expect(rec.secret_col).to eq('my-ip')
    # class-level encrypt/decrypt
    c = InPlaceTest.encrypt_value('x')
    expect(InPlaceTest.decrypt_value(c)).to eq('x')
  end

  it 'returns raw ciphertext and logs a warning when decryption fails' do
    rec = InPlaceTest.new
    # put invalid ciphertext directly into column
    rec.write_attribute(:secret_col, 'not-a-valid-ciphertext')
    expect(Rails.logger).to receive(:warn).with(/Failed to decrypt InPlaceTest#secret_col/)
    expect(rec.secret_col).to eq('not-a-valid-ciphertext')
  end

  it 'writes nil when setter given nil' do
    rec = InPlaceTest.new
    rec.secret_col = nil
    expect(rec.read_attribute(:secret_col)).to be_nil
  end
end
