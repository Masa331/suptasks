class TimeDuration
  attr_accessor :duration

  def initialize(duration)
    @duration = duration
  end

  def +(other_duration)
    TimeDuration.new(duration + other_duration.duration)
  end

  def to_s
    if duration > 60
      hours = duration / 60
      minutes = duration % 60

      "#{hours}h #{minutes}m"
    else
      duration.to_s + "m"
    end
  end
end
