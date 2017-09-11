class JournalSerializer < ActiveModel::Serializer
  attributes :id,
  :name,
  :logo_url,
  :paper_types,
  :manuscript_css,
  :staff_email,
  :pdf_allowed,
  :coauthor_confirmation_enabled

  has_many :manuscript_manager_templates,
           serializer: PaperTypeSerializer

  def coauthor_confirmation_enabled
    object.setting('coauthor_confirmation_enabled').value
  end
end
