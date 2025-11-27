class UserService
    def self.get_user_id(username)
        user = User.find_by(username: username)
        user&.index
    rescue => e
        Rails.logger.error("Service error getting user ID: #{e}")
        nil
    end

    def self.register(params)
        if get_user_id(params[:username])
            raise "Username already exists"
        end

        user = User.new(
            username: params[:username],
            password: params[:password]
        )

        if user.save
            user
        else
            raise StandardError.new(user.errors.full_messages.join(", "))
        end
    end

    def self.login(username:, password:)
        user = User.find_by(username: username)
        raise StandardError.new("Invalid username") unless user

        unless user.authenticate(password)
            raise StandardError.new("Invalid password")
        end

                # Update last_login timestamp
                begin
                    user.update_columns(last_login: Time.current)
                rescue => e
                    Rails.logger.error("Failed to update last_login for user=#{user.id}: #{e}")
                end

                { id: user.id, username: user.username, message: "Login successful" }
    end

    def self.logout(username)
        user = User.find_by(username: username)
        raise StandardError.new("User not found") unless user

        { id: user.id, username: user.username, message: "Logout successful" }
    end
end
