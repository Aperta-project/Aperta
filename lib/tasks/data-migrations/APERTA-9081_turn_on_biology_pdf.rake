namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-9081 Turn on PDF support in production (Biology)
        * Turn on the feature flag for production at the journal level for Biology, enabling all PDF/LaTeX support.
    DESC
    task turn_on_pdf_support_for_biology: :environment do
      biology = Journal.find_by(name: "PLOS Biology")
      biology.update_attributes!(pdf_allowed: true) if biology
    end
    task turn_off_pdf_support_for_biology: :environment do
      biology = Journal.find_by(name: "PLOS Biology")
      biology.update_attributes!(pdf_allowed: false) if biology
    end
  end
end
