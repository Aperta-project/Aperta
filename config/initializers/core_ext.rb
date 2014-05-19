#
# Allows pulling nested values from a hash without worrying about key existence
# examples:
#   { h: { a: "1", b: "2" } }.get(:h, :b)     # "2"
#   { h: { a: "1", b: "2" } }.get(:h, :z)     # nil
#
Hash.class_eval do
  def get(key, *keys)
    if keys.empty?
      self[key]
    else
      fetch(key, {}).get(*keys)
    end
  end
end
