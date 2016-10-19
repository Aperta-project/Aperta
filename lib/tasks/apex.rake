namespace :apex do
  desc 'Upload package to Apex'
  desc <<-USAGE.strip_heredoc
    This uploads a package to Apex
    Usage: rake 'apex:ftp_upload[HOST, USER, PASSWORD, FINAL_FILENAME, FILEPATH]'
  USAGE
  task :ftp_upload, [:host, :user, :password, :filename, :filepath] => [:environment]  do |t, args|
    filename = args['filename'] || 'test.jpg'
    filepath = args['filepath'] || Rails.root.join('public', 'images', 'cat-scientists-3.jpg')

    host = args['host']
    user = args['user']
    password = args['password']

    ftp_url = "ftp://#{CGI.escape(user)}:#{CGI.escape(password)}@#{CGI.escape(host)}"
    FtpUploaderService.new(
      url: ftp_url,
      final_filename: filename,
      file_io: File.open(filepath)
    ).upload
  end
end
