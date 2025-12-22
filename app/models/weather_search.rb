class WeatherSearch < ApplicationRecord
  validates :city, presence: true
  include InPlaceEncryption

  # Store encrypted data in the `user_ip` column itself
  in_place_encrypts :user_ip
end
