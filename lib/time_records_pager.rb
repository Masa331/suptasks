# This class knows how to page TimeRecord dataset. You initialize it with dataset and then call one of the
#   pagination methods.
#
#   All pagination methods should returns array of TimeRecords, each representing one page.
#   By counting the returned array you get back number of pages.
class TimeRecordsPager
  attr_reader :time_records

  def initialize(dataset)
    @time_records = dataset
  end

  # Splits dataset into pages each holding given number of days
  #
  # @param number_of_days [Integer]
  #
  # @return array of TimeRecords [Array]
  def by_number_of_days(number_of_days)
    page_count = page_count_for_number_of_days(number_of_days)

    1.upto(page_count).map do |page_number|
      start_date = Date.today - (number_of_days * page_number)
      # HACK: +1 cos Date.today.to_time returns eg. 1.1.2015 00:00 but we want in fact 23:59 and
      #    00:00 next day is almost the same
      end_date   = (start_date + number_of_days + 1)

      TimeRecords.new(time_records.where('started_at >= ? ', start_date).where('started_at <= ? ', end_date))
    end
  end

  def page_count_for_number_of_days(number_of_days)
    oldest_record = time_records.order(:started_at).first

    return 1 if oldest_record.nil? || oldest_record.started_at.to_date == Date.today

    days_from_first_record = (Date.today - oldest_record.started_at.to_date).to_i

    (days_from_first_record/number_of_days.to_f).ceil
  end
end
