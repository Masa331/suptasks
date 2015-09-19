require 'logger'

class SupLogger
  def self.logger
    @@logger ||= Logger.new('suptasks.log')
  end

  def self.error(message)
    logger.error(message)
  end
end
