class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  
  # Ensure timestamps exist for new users in case records are created
  # outside the usual ActiveRecord flow or via raw SQL.
  before_create :ensure_timestamps

  private

  def ensure_timestamps
    now = Time.current
    self.created_at ||= now
    self.updated_at ||= now
  end
end
