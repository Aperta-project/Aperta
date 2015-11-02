module TahiEpub
  class Storage
    attr_reader :job_id

    def initialize(job_id)
      @job_id = job_id
    end

    def connection
      @connection ||= Fog::Storage.new({
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
      })
    end

    def directory
      connection.directories.get(ENV['S3_BUCKET'])
    end

    def source_filename
      "manuscript-source.epub"
    end

    def result_filename
      "manuscript-converted.epub"
    end

    def source
      @source ||= get_source
    end

    def get_source
      directory.files.get("#{job_id}/#{source_filename}")
    end

    def result
      @result ||= get_result
    end

    def get_result
      directory.files.get("#{job_id}/#{result_filename}")
    end

    def result_stream=(stream)
      directory.files.create key: "#{job_id}/#{result_filename}",
                             body: stream
    end

    def source_stream=(stream)
      directory.files.create key: "#{job_id}/#{source_filename}",
                             body: stream
    end

    def put(filename, file)
      directory.files.create key: "#{job_id}/#{filename}",
                             body: file.read
    end

    def get(filename)
      directory.files.get "#{job_id}/#{filename}"
    end
  end
end
