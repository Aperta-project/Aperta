class SupportingInformationFile::Updated::EventStream < EventStreamSubscriber

  def channel
    record.paper
  end

  def payload
    SupportingInformationFileSerializer.new(record).to_json
  end

end
