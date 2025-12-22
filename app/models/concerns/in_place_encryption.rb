module InPlaceEncryption
  extend ActiveSupport::Concern

  class_methods do
    def in_place_encrypts(*attributes)
      # use find to operate on the first provided attribute
      attr_name = attributes.find { true }
      return unless attr_name

      define_method(attr_name) do
        # Return stored HMAC (non-reversible). This value is not the plaintext IP.
        read_attribute(attr_name)
      end

      define_method("#{attr_name}=") do |val|
        if val.nil?
          write_attribute(attr_name, nil)
        else
          # Compute keyed HMAC (non-reversible) so same IP yields same stored value.
          secret = self.class.ip_hash_secret
          h = OpenSSL::HMAC.hexdigest("SHA256", secret, val.to_s)
          write_attribute(attr_name, h)
        end
      end
    end
    def ip_hash_secret
      # Use SECRET_KEY_BASE as the single source of secret for HMAC
      ENV.fetch("SECRET_KEY_BASE") { Rails.application.secret_key_base || (raise KeyError, "SECRET_KEY_BASE not set and Rails.application.secret_key_base is nil") }
    end
  end
end
