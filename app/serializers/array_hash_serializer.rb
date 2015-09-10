class ArrayHashSerializer
  def self.load(array)
    array.map(&:with_indifferent_access) if array
  end

  def self.dump(array)
    array
  end
end

