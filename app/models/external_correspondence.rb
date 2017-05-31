# External Correspondence
#
# To handle communication on a paper which is not generated within TAHI
class ExternalCorrespondence < Correspondence
  validates :description, :sender, :recipients, :body, presence: true,
                                                       allow_blank: false

  belongs_to :paper

  def serialize_copied_recipients
    # Make sure the copied recipients fit into a string
  end

  def unserialize_copied_recipients
    # build the string into a list of copied recipients, if needed
  end
end
