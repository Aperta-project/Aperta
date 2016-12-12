class JournalSerializer < ActiveModel::Serializer
  attributes :id,
    :name,
    :logo_url,
    :paper_types,
    :manuscript_css,
    :staff_email,
    :pdf_allowed
end
