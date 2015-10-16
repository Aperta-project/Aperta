class VersionedText::Created::SnapshotMetadata

  def self.call(_event_name, event_data)
    binding.pry
    versioned_text = event_data[:versioned_text]

    puts "version-text created"
  end

end
