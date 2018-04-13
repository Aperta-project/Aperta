# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

namespace :apex do
  desc 'Upload package to Apex'
  desc <<-USAGE.strip_heredoc
    This uploads a package to Apex
    Usage: rake 'apex:ftp_upload[HOST, USER, PASSWORD, FINAL_FILENAME, FILEPATH]'
  USAGE
  task :ftp_upload, [:host, :user, :password, :filename, :filepath] => [:environment]  do |_t, args|
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
