require 'logger'

class SupLogger
  def self.logger
    @@logger ||= Logger.new(Configuration.log_file)
  end

  def self.error(message)
    logger.error(message)
  end
end
