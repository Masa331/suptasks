class User
  attr_accessor :email, :name

  def initialize(email:, name:)
    self.email = email
    self.name = name
  end
end
