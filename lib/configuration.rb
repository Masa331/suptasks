class Configuration
  def self.db_dir
    "databases/"
  end

  def self.log_file
    'suptasks.log'
  end

  def self.google_client_id
    ENV['GOOGLE_CLIENT_ID']
  end

  def self.google_client_secret
    ENV['GOOGLE_CLIENT_SECRET']
  end

  def self.cookie_secret
    ENV['COOKIE_SECRET']
  end
end
