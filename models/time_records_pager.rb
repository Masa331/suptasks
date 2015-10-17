class TimeRecordsPager
  attr_reader :time_records

  def initialize(dataset)
    @time_records = dataset
  end

  def by_number_of_days(number_of_days)
    number_of_pages =
      begin
        first_time_record_created = TimeRecord.order(:started_at).first
        dates_from_first_record = (Date.today - first_time_record_created.started_at.to_date).to_i

        (dates_from_first_record/number_of_days.to_f).ceil
      end

    number_of_pages.times.map do |page_number|
      start_date = Date.today - ((number_of_days * page_number) - 1) # -1 for start day
      end_date   = start_date + (number_of_days + 2) # +2 for current day and -1 offset :)

      TimeRecords.new(time_records.where('started_at > ? ', start_date).where('started_at < ? ', end_date))
    end
  end
end
