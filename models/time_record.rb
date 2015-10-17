class TimeRecord < Sequel::Model
  many_to_one :task

  def self.today
    # All times are stored in UTC. Huraaaaay!! :)
    start_of_the_day = Time.parse('00:01').utc

    where('started_at > ?', start_of_the_day)
  end

  def self.between_dates(start_date, end_date)
    where('started_at > ? ', start_date).where('started_at < ? ', end_date)
  end

  def after_validation
    value =
      begin
        Time.parse(started_at.to_s)
      rescue ArgumentError
        Time.now
      end

    self.started_at = value.to_s
    super
  end

  def to_duration
    TimeDuration.new(duration)
  end

  def created_at_formated
    created_at.strftime("%e.%-m.%Y %H:%M (UTC)")
  end

  def started_at_formated
    started_at.strftime("%e.%-m.%Y %H:%M (UTC)")
  end
end
