
# Every time assets:precomile is called, trigger pdfjsviewer:copy_non_digest_assets afterwards
Rake::Task["assets:precompile"].enhance do
  Rake::Task["assets:bypass_pipeline:copy_pdfjsviewer"].invoke
end

namespace :assets do
  namespace :bypass_pipeline do
    desc <<-DESC.strip_heredoc
      Copy over pdfjs viewer assets (maps, images, locales)

      APERTA-7828
    DESC
    task copy_pdfjsviewer: :environment do
      public_assets = File.join(Rails.root, "public/assets/")
      pdfjsviewer_vendor = File.join(Rails.root, "vendor/assets/pdfjs-viewer/pdfjsviewer")

      FileUtils.cp_r pdfjsviewer_vendor, public_assets
    end
  end
end
