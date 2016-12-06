
# Every time assets:precomile is called, trigger pdfjsviewer:copy_non_digest_assets afterwards
Rake::Task["assets:precompile"].enhance do
  Rake::Task["pdfjsviewer:copy_non_digest_assets"].invoke
end

namespace :pdfjsviewer do
  task copy_non_digest_assets: :"assets:environment" do
    public_assets = File.join(Rails.root, "public/assets/")
    pdfjsviewer_vendor = File.join(Rails.root, "vendor/assets/pdfjs-viewer/pdfjsviewer")

    FileUtils.cp_r pdfjsviewer_vendor, public_assets
  end
end
