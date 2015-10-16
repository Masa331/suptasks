class TimeRecord < Sequel::Model
  many_to_one :task

  def self.today
    # All times are stored in UTC. Huraaaaay!! :)
    start_of_the_day = Time.parse('00:01').utc

    where('created_at > ?', start_of_the_day)
  end

  def self.between_dates(start_date, end_date)
    where('created_at > ? ', start_date).where('created_at < ? ', end_date)
  end

  def to_duration
    TimeDuration.new(duration)
  end

  def created_at_formated
    created_at.strftime("%e.%-m.%Y %H:%M (UTC)")
  end
end
