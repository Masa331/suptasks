class TimeRecord < Sequel::Model

  many_to_one :task

  def self.today
    # All times are stored in UTC. Huraaaaay!! :)
    start_of_the_day = Time.parse('00:01').utc

    where('created_at > ?', start_of_the_day)
  end

  def to_duration
    TimeDuration.new(duration)
  end
end
