# frozen_string_literal: true

module OmniAuth
  class NonceStore
    MAXIMUM_AGE = 30.minutes

    def self.build_cache_key(nonce)
      "omniauth_nonce_#{nonce}"
    end

    def self.add(value)
      nonce = Devise.friendly_token
      cache.write(build_cache_key(nonce), value, expires_in: MAXIMUM_AGE)
      nonce
    end

    def self.read(nonce)
      cache.read(build_cache_key(nonce))
    end

    def self.delete(nonce)
      cache.delete(build_cache_key(nonce))
    end

    def self.pop(nonce)
      value = read(nonce)
      delete(nonce) if value
      value
    end

    def self.cache
      @cache ||= ActiveSupport::Cache.lookup_store(:file_store, '/tmp/cache/omniauth')
    end
  end
end
