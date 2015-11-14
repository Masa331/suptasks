require 'sequel'

class TaskFilter
  class DescriptionFilter
    attr_accessor :description

    def initialize(description)
      @description = description
    end

    def to_sql
      if @description
        Sequel.ilike(:description, "%#{@description}%")
      else
        Sequel.expr(true)
      end
    end
  end

  class StatusFilter
    attr_accessor :status

    def initialize(status)
      @status =
        case status
        when '0' then false
        when '1' then true
        end
    end

    def to_sql
      if @status.nil?
        Sequel.expr(true)
      else
        Sequel.expr(completed: @status)
      end
    end
  end

  attr_accessor :description_filter, :status_filter

  def initialize(params = {})
    @description_filter = DescriptionFilter.new(params.fetch('description', nil))
    @status_filter = StatusFilter.new(params.fetch('status', '0'))
  end

  def to_sql
    @description_filter.to_sql.&(@status_filter.to_sql)
  end
end
