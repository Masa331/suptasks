require_relative "test_helper"
require_relative "../lib/time_duration"

class TimeDurationTest < Minitest::Test
  def test_addition
    duration1 = TimeDuration.new(30)
    duration2 = TimeDuration.new(60)

    assert_instance_of TimeDuration, duration1 + duration2
    assert_equal 90, (duration1 + duration2).duration
  end

  def test_comparing
    ten_minutes = TimeDuration.new(10)
    one_hour = TimeDuration.new(60)

    assert ten_minutes < one_hour
    assert one_hour > ten_minutes

    assert(ten_minutes < 20)
    assert(ten_minutes > 5)
  end

  def test_to_i
    duration = TimeDuration.new(30)

    assert_equal 30, duration.to_i
  end

  def test_to_s
    duration = TimeDuration.new(60)
    assert_equal '1h', duration.to_s

    duration = TimeDuration.new(61)
    assert_equal '1h 1m', duration.to_s

    duration = TimeDuration.new(15)
    assert_equal '15m', duration.to_s

    duration = TimeDuration.new(615)
    assert_equal '10h 15m', duration.to_s
  end
end
