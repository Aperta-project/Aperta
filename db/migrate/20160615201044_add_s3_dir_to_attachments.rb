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

# This creates a column on all of the attachment-like models to cache
# the s3 directory. This will help us out later when we need to reference where
# an attachment is located between when we update the attachment uploader and
# haven't moved the file on s3.
class AddS3DirToAttachments < ActiveRecord::Migration
  def up
    # attachment mounted as file "uploads/attachments/#{model.id}/attachment/file/#{model.id}"
    add_column :attachments, :s3_dir, :text
    execute <<-SQL
      UPDATE attachments
      SET s3_dir = CONCAT('uploads/attachments/', id, '/attachment/file/', id)
    SQL

    # figure mounted as attachment "uploads/paper/#{model.paper.id}/figure/attachment/#{model.id}"
    add_column :figures, :s3_dir, :text
    execute <<-SQL
      UPDATE figures
      SET s3_dir = CONCAT('uploads/paper/', paper_id, '/figure/attachment/', id)
    SQL

    # supporting_information_files mounted as attachment "uploads/attachments/#{model.id}/supporting_information_file/attachment/#{model.id}"
    add_column :supporting_information_files, :s3_dir, :text
    execute <<-SQL
      UPDATE supporting_information_files
      SET s3_dir = CONCAT('uploads/attachments/', id, '/supporting_information_file/attachment/', id)
    SQL

    # question_attachments mounted as attachment "uploads/question/#{model.nested_question_answer_id}/question_attachment/#{model.id}"
    add_column :question_attachments, :s3_dir, :text
    execute <<-SQL
      UPDATE question_attachments
      SET s3_dir = CONCAT('uploads/question/', nested_question_answer_id, '/question_attachment/', id)
    SQL
  end

  def down
    remove_column :question_attachments, :s3_dir
    remove_column :supporting_information_files, :s3_dir
    remove_column :figures, :s3_dir
    remove_column :attachments, :s3_dir
  end
end
