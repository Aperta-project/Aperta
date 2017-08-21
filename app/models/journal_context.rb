# Provides a template context for Journals
class JournalContext < TemplateContext
  def self.merge_field_definitions
    [{ name: :name },
     { name: :logo_url },
     { name: :staff_email }]
  end

  whitelist :name, :logo_url, :staff_email
end
