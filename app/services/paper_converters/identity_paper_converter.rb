module PaperConverters
  # A paper 'converter' that provides the url of the original document
  class IdentityPaperConverter < RedirectingPaperConverter
    def download_url
      Attachment.authenticated_url_for_key(@versioned_text.s3_full_path)
    end
  end
end
