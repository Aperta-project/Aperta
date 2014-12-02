class Doi
  FORMAT = /\w+\/\w+\.\d+/

  def self.valid?(doi_string)
    String(doi_string).match(FORMAT).present?
  end
end
