module InPlaceEncryption
  extend ActiveSupport::Concern

  class_methods do
    def in_place_encrypts(*attributes)
      attributes.each do |attr_name|
        define_method(attr_name) do
          ciphertext = read_attribute(attr_name)
          return nil if ciphertext.nil?
          begin
            self.class.decrypt_value(ciphertext)
          rescue => e
            # If decryption fails, return the raw ciphertext to avoid breaking reads
            Rails.logger.warn("Failed to decrypt #{self.class.name}##{attr_name}: ") if defined?(Rails)
            ciphertext
          end
        end

        define_method("#{attr_name}=") do |val|
          if val.nil?
            write_attribute(attr_name, nil)
          else
            ciphertext = self.class.encrypt_value(val.to_s)
            write_attribute(attr_name, ciphertext)
          end
        end
      end
    end

    def encrypt_value(value)
      encryptor.encrypt_and_sign(value)
    end

    def decrypt_value(ciphertext)
      encryptor.decrypt_and_verify(ciphertext)
    end

    def encryptor
      key = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base || ENV["SECRET_KEY_BASE"]).generate_key("in_place_encryption", ActiveSupport::MessageEncryptor.key_len)
      ActiveSupport::MessageEncryptor.new(key)
    end
  end
end
