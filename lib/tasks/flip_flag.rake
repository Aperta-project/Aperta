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

namespace :flip do
  desc <<-USAGE.strip_heredoc
    This flips a feature flag either on or off for use in the app.
    :feature and :journal_id and :boolean is required

    Turn feature on idempotently
      Usage: rake flip:toggle[<feature_column_on_journal>,<journal_id>,true]
      Example: rake flip:toggle['pdf_allowed',3,true] (Will turn on the feature flag for pdf submissions for Journal 3)
  USAGE
  task :toggle, [:feature_string, :journal_id, :boolean] => :environment do |_, args|
    journal = Journal.find(args[:journal_id])
    bool = if args[:boolean] == 'false'
             false
           elsif args[:boolean] == 'true'
             true
           else
             args[:boolean]
           end
    journal.update_column(args[:feature_string].to_sym, bool)
    STDOUT.puts("Updating #{journal.name} to have feature #{args[:feature_string]} to #{args[:boolean]}")
  end
end
