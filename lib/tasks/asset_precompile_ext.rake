# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.


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
