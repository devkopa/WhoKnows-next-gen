class UserRepository
  class << self

    def get_user_id(username)
      user = User.find_by(username: username)
      user&.id
    end

    def add_user(attributes)
      user = User.new(attributes)
      if user.save
        { id: user.id, username: user.username}
      else
        raise StandardError.new(user.errors.full_messages.join(", "))
      end
    end

    def login(username)
      user = User.find_by(username: username)
      return nil unless user

      { id: user.id, username: user.username, password: user.password_digest }
    end

    def logout(username)
      Rails.logger.info("Lpgging #{username} with user id: #{user_id} out")
      true
    end
  end
end