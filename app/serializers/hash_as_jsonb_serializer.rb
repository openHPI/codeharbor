# frozen_string_literal: true

class HashAsJsonbSerializer
  def self.dump(hash)
    hash
  end

  def self.load(hash)
    # (hash.is_a?(Hash) ? hash : {}).with_indifferent_access
    hash.is_a?(Hash) ? hash.symbolize_keys : {}
  end
end
