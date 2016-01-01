class TimeRecord < Sequel::Model(TASK_DB[:time_records])
  many_to_one :task

  def self.between_dates(start_date, end_date)
    where('started_at > ? ', start_date).where('started_at < ? ', end_date)
  end

  def self.today
    # All times are stored in UTC. Huraaaaay!! :)
    start_of_the_day = Time.parse('00:01').utc

    where('started_at > ?', start_of_the_day)
  end

  def after_create
    touch_associations
    super
  end

  def after_validation
    self.started_at = Time.parse(started_at.to_s) rescue Time.now
    super
  end

  def duration
    TimeDuration.new(super)
  end
end

TimeRecord.plugin :touch, associations: [:task]
