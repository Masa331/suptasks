require 'bcrypt'

class User < Sequel::Model(CUSTOMER_DB[:users])
  include BCrypt

  def self.find_authenticated(email, given_password)
    user = User.where(email: email).first

    if user
      user_password = Password.new(user.password)

      user if user_password == given_password
    end
  end
end
