namespace :apex do
  desc 'Upload package to Apex'
  desc <<-USAGE.strip_heredoc
    This uploads a package to Apex
    Usage: rake 'apex:ftp_upload[HOST, USER, PASSWORD, FINAL_FILENAME, FILEPATH]'
  USAGE
  task :ftp_upload, [:host, :user, :password, :filename, :filepath] => [:environment]  do |t, args|
    filename = args['filename'] || 'test.jpg'
    filepath = args['filepath'] || Rails.root.join('public', 'images', 'cat-scientists-3.jpg')

    FtpUploaderService.new(
      host: args['host'],
      passive_mode: true,
      user: args['user'],
      password: args['password'],
      port: 21,
      filename: filename,
      filepath: filepath
    ).upload
  end

  task export: :environment do
    $stdout.puts 'Beginning export'
    paper = Paper.find(917)
    download = DownloadApexZip.new(paper)
    download.export
  end
end
