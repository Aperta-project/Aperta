class VersionedText::Updated::SnapshotMetadata

  def self.call(_event_name, event_data)
    binding.pry    
    puts "versioned-text updated"
  end

end
