module PaperConverters
  # An abstract class used for conversions that are synchronous
  # This means that the conversion is meant to occur within the
  # request cycle and not in a separate job.
  class SynchronousPaperConverter < PaperConverter
    def output_data
      raise NotImplementedError
    end

    def output_filename
      raise NotImplementedError
    end

    def output_filetype
      raise NotImplementedError
    end
  end
end
