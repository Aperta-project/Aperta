Fog.mock!
Fog.credentials = CarrierWave::Uploader::Base.fog_credentials
connection = Fog::Storage.new(provider: "AWS")
connection.directories.create(key: ENV["S3_BUCKET"])
