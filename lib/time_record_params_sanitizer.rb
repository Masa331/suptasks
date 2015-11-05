# timeRecordParamsSanitizer takes hash of params from html form and return other hash
#   with only params which are permitted for Task. It's similar to Rails permitted params
class TimeRecordParamsSanitizer
  attr_reader :params

  PERMITTED_KEYS = ['task_id', 'description', 'duration', 'started_at']

  def initialize(params)
    @params = params
  end

  def call
    params.keep_if { |key, _| PERMITTED_KEYS.include? key }
  end
end
