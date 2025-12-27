class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { new_record? || password.present? }

  # Ensure timestamps exist for new users in case records are created
  # outside the usual ActiveRecord flow or via raw SQL.
  before_create :ensure_timestamps

  private

  def ensure_timestamps
    now = Time.current
    unless respond_to?(:created_at)
      define_singleton_method(:created_at) { @created_at }
      define_singleton_method(:created_at=) { |v| @created_at = v }
    end
    self.created_at ||= now

    unless respond_to?(:updated_at)
      define_singleton_method(:updated_at) { @updated_at }
      define_singleton_method(:updated_at=) { |v| @updated_at = v }
    end
    self.updated_at ||= now
  end
end
