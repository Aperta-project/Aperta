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

#
# Compares two arrays
# examples:
#   Array.compare( [1,2,3], [3,4,5] )
#   #=> {:added=>[4, 5], :common=>[3], :removed=>[1, 2]}
#
Array.instance_eval do
  def compare(old, new)
    { added: new - old,
      common: old & new,
      removed: old - new }
  end
end
