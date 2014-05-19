Hash.class_eval do
  def get(key, *keys)
    if keys.empty?
      self[key]
    else
      fetch(key, {}).get(*keys)
    end
  end
end
