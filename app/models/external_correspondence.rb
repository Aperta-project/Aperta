# External Correspondence
#
# To handle communication on a paper which is not generated within TAHI
class ExternalCorrespondence < Correspondence
  validates :description, :sender, :recipients,
            :subject, :body, :cc, :bcc, presence: true,
                                        allow_blank: false

  belongs_to :paper

  alias_attribute :content, :body
end
