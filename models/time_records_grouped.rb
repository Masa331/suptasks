class TimeRecordsGrouped
  attr_reader :description

  def initialize(description, duration)
    @description = description
    @duration = duration
  end

  def to_duration
    TimeDuration.new(@duration)
  end
end
