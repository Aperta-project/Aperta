require 'fog'

class HerokuExporter
  attr_accessor :source_file, :database_name, :s3_file, :s3_secure_url

  S3_URL_EXPIRATION_MINUTES = 5

  def initialize(database_name, source_file)
    @database_name = database_name
    @source_file = source_file
  end

  def dump!
    command = Thread.new do
      system("pg_dump -F c -v -U tahi -h localhost #{database_name} -f #{Rails.root.join('tmp', source_file)}")
    end
    command.join
  end

  def copy_to_s3(access_key_id, secret_access_key)
    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => access_key_id,
      :aws_secret_access_key    => secret_access_key
    })

    directory = connection.directories.new(
      :key    => "tahi-development",
      :public => false
    )

    s3_file = "load_testing/#{source_file}"

    file = directory.files.create(
      :key    => s3_file,
      :body   => File.open(Rails.root.join('tmp', source_file)),
      :public => true
    )

    create_s3_url(file)
  end

  def export_to_heroku!
    Bundler.with_clean_env do
      command = Thread.new do
        system(" heroku pgbackups:restore DATABASE_URL '#{s3_secure_url}' --app tahi-performance")
      end
      command.join
    end
  end


  private

    def create_s3_url(file)
      sc3_secure_url = file.url(S3_URL_EXPIRATION_MINUTES.minutes.from_now)
    end

end
