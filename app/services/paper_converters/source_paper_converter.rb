module PaperConverters
  # A paper 'converter' that provides the url of the original document
  class SourcePaperConverter < RedirectingPaperConverter
    def download_url
      Attachment.authenticated_url_for_key(
        @paper_version.s3_full_sourcefile_path
      )
    end
  end
end
