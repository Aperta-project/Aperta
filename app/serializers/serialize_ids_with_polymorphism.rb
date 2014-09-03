module SerializeIdsWithPolymorphism
  def self.call(associated_object)
    associated_object.map do |item|
      SerializeIdWithPolymorphism.call(item)
    end
  end
end
