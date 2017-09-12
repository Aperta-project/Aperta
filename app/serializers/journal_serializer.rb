class JournalSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :logo_url,
    :paper_types,
    :manuscript_css,
    :staff_email,
    :pdf_allowed
  has_many :manuscript_manager_templates,
           serializer: PaperTypeSerializer
end
