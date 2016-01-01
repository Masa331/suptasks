require 'digest/sha1'

class ETagGenerator
  def self.call(model)
    Digest::SHA1.hexdigest("#{model.class.to_s}#{model.id}#{model.updated_at}")
  end
end
