# Provides a template context for Journals
class JournalContext < TemplateContext
  whitelist :name, :logo_url, :staff_email
end
