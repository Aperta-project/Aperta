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
