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

    1.upto(number_of_pages).map do |page_number|
      start_date = Date.today - (number_of_days * page_number)
      # HACK: +1 cos Date.today.to_time returns eg. 1.1.2015 00:00 but we want in fact 23:59 and
      #    00:00 next day is almost the same
      end_date   = (start_date + number_of_days + 1)

      TimeRecords.new(time_records.where('started_at >= ? ', start_date).where('started_at <= ? ', end_date))
    end
  end
end
