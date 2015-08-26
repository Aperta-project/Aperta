class SupportingInformationFile::Updated::EventStream < EventStreamSubscriber

  def channel
    private_channel_for(record.paper)
  end

  def payload
    SupportingInformationFileSerializer.new(record).as_json
  end

end
