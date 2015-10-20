module CloudServices
  class S3Service

    def connection
      CloudServices::S3Service::Connector.instance.connection
    end

    class Connector
      include Singleton

      attr_reader :connection

      def initialize
        @connection = Fog::Storage.new(
          provider:             'AWS',
          region:                ENV['AWS_REGION'],
          aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
          aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        )
      end
    end

  end
end
