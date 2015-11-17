require 'sequel'

class TaskFilter
  class DescriptionFilter
    def initialize(description, dataset)
      @description = description
      @dataset = dataset
    end

    def call
      if @description
        @dataset.where(Sequel.ilike(:description, "%#{@description}%"))
      else
        @dataset
      end
    end
  end

  class StatusFilter
    def initialize(status, dataset)
      @status = status
      @dataset = dataset
    end

    def call
      if @status.nil?
        @dataset
      else
        @dataset.where(completed: @status)
      end
    end
  end

  attr_accessor :description, :status, :dataset

  def initialize(params = {}, dataset)
    @description = params.fetch('description', nil)
    @status = parse_status(params.fetch('status', '0'))
    @dataset = dataset
  end

  def call
    filtered = DescriptionFilter.new(description, dataset).call
    StatusFilter.new(status, filtered).call
  end

  private

  def parse_status(status)
    case status
    when '0' then false
    when '1' then true
    end
  end
end
