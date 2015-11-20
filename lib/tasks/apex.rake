# rake 'apex:ftp_upload[HOST, USER, PASSWORD, FILENAME, FILEPATH]'

namespace :apex do
  desc "Upload package to Apex"
  task :ftp_upload, [:host, :user, :password, :filename, :filepath] => [:environment]  do |t, args|
    filename = args['filename'] || 'test.jpg'
    filepath = args['filepath'] || Rails.root.join('public', 'images', 'cat-scientists-3.jpg')

    FtpUploaderWorker.new.perform(
      host: args['host'],
      passive_mode: true,
      user: args['user'],
      password: args['password'],
      port: 21,
      filename: filename,
      filepath: filepath
    )
  end
end
