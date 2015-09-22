class TimeRecord < Sequel::Model
  many_to_one :task

  def self.last_24_hours
    # All times are stored in UTC. Huraaaaay!! :)
    where('created_at > ?', Time.now.utc - (24 * 60 * 60))
  end
end
