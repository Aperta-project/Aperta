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

# This updates the primary key sequence for the attachments table. PostgreSQL
# doesn't automatically set this after INSERTing rows unless nextval() is used.
# This migration is safe to run forwards and backwards and will work if there
# are 0 or more records.
class ResetAttachmentPrimaryKeySequence < ActiveRecord::Migration
  def up
    update_attachments_id_seq
  end

  def down
    update_attachments_id_seq
  end

  private

  def update_attachments_id_seq
    # Use COALESCE in case there are no records in the table, in that case
    # set the sequence ID to 1. For more information see:
    #
    #   https://www.postgresql.org/docs/current/static/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL
    #
    # Pass in false to setval as its second argument to indicate that this
    # value should be provided the next time nextval() is called. For more
    # information see:
    #
    #   https://www.postgresql.org/docs/9.5/static/functions-sequence.html
    #
    execute <<-SQL
     SELECT setval('attachments_id_seq', coalesce((select max(id)+1 from attachments), 1), false);
    SQL
  end
end
