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

# Adds necessary stuff for tokens
class AddTokenToSupportingInformationFile < ActiveRecord::Migration
  # stands in for model, ensures that regenerate_token is defined
  class SupportingInformationFile < ActiveRecord::Base
    def regenerate_token
      update_attributes! token: SecureRandom.hex(24)
    end
  end

  def change
    SupportingInformationFile.reset_column_information
    add_column :supporting_information_files, :token, :string
    add_index :supporting_information_files, :token, unique: true

    reversible do |dir|
      dir.up do
        puts "Adding tokens for #{SupportingInformationFile.all.count} previous supporting_information_files..."
        SupportingInformationFile.all.each {|file| file.regenerate_token }
        puts 'Done.'
      end
    end

  end
end
