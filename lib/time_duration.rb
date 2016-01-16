class TimeDuration
  attr_reader :duration

  def initialize(duration = 0)
    @duration = duration
  end

  def +(other_duration)
    TimeDuration.new(duration + other_duration.duration)
  end

  def >(other_duration)
    to_i > other_duration.to_i
  end

  def <(other_duration)
    to_i < other_duration.to_i
  end

  def <=>(other)
    duration <=> other.duration
  end

  def to_i
    duration
  end

  def zero?
    duration.zero?
  end

  def to_s
    if duration >= 60
      hours   = duration / 60
      minutes = duration % 60

      if minutes > 0
        "#{hours}h #{minutes}m"
      else
        "#{hours}h"
      end
    else
      duration.to_s + 'm'
    end
  end
end
