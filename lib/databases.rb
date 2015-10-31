class Databases < SimpleDelegator
  def initialize(databases)
    super
  end

  def find_by_user_email(email)
    find { |database| database.user_email == email }
  end
end
