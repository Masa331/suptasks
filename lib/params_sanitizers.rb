# ParamsSanitizer takes hash of params from html form and return other hash
#   with only params which are permitted. It's similar to Rails permitted params

module BaseParamsSanitizer
  def self.included(klass)
    klass.extend ClassMethods
  end

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    params.keep_if { |key, _| permitted_keys.include? key }
  end

  module ClassMethods
    def call(params)
      new(params).call
    end
  end
end

class TaskParamsSanitizer
  include BaseParamsSanitizer

  def permitted_keys
    ['description', 'time_cost', 'tags']
  end
end

class TimeRecordParamsSanitizer
  include BaseParamsSanitizer

  def permitted_keys
    ['task_id', 'description', 'duration', 'started_at']
  end
end
