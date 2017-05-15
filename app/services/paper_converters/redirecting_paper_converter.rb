module PaperConverters
  # Interface for paper converters that don't actually convert, they just
  # redirect the user to an extant file
  class RedirectingPaperConverter < PaperConverter
    def download
      raise NotImplementedError
    end
  end
end
