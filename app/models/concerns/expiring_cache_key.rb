module ExpiringCacheKey
  extend ActiveSupport::Concern

  def expire_cache_key
    Rails.cache.write(cache_iterator_key, cache_iterator + 1)
  end

  def cache_iterator
    Rails.cache.fetch(cache_iterator_key) { 0 }
  end

  def cache_key
    "#{self.class}-#{id}-#{cache_iterator}"
  end

  private

  def cache_iterator_key
    "#{self.class}-#{id}-cache-iterator"
  end
end
