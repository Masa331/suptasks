# This class knows how to page TimeRecord dataset. You initialize it with dataset and then call one of the
#   pagination methods.
#
#   All pagination methods should returns array of TimeRecords, each representing one page.
#   By counting the returned array you get back number of pages.
class TimeRecordsPager
  attr_reader :time_records, :number_of_days

  def initialize(dataset, number_of_days)
    @time_records = dataset
    @number_of_days = number_of_days
  end

  def self.by_number_of_days(dataset, number_of_days)
    new(dataset, number_of_days).call
  end

  # Splits dataset into pages each holding given number of days
  #
  # @param number_of_days [Integer]
  #
  # @return array of TimeRecords [Array]
  def call
    1.upto(page_count).map do |page_number|
      start_date = Date.today - (number_of_days * page_number)
      # HACK: +1 cos Date.today.to_time returns eg. 1.1.2015 00:00 but we want in fact 23:59 and
      #    00:00 next day is almost the same
      end_date   = (start_date + number_of_days + 1)

      TimeRecords.new(time_records.where('started_at >= ? ', start_date).where('started_at <= ? ', end_date))
    end
  end

  private

  def page_count
    return 1 if time_records.empty?

    oldest_record = time_records.order(:started_at).first

    days_from_first_record = (Date.today - oldest_record.started_at.to_date).to_i

    return 1 if days_from_first_record.zero?

    (days_from_first_record/number_of_days.to_f).ceil
  end
end
