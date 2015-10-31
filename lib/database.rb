require 'sequel'
require 'base64'

class Database
  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def user_email
    db_name = path.split('/').last
    db_name = db_name.gsub('.db', '')

    name = Base64.urlsafe_decode64(db_name)
    name.gsub('_default', '')
  end

  def connect!
    self.tap do |db|
      connection
    end
  end

  def connection
    @connection ||= Sequel.sqlite(path)
  end

  def inspect
    "#<Database path=\"#{path}\" user_email=\"#{user_email}\">"
  end
end
