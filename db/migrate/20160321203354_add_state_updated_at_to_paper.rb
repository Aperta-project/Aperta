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

# Adds state_updated_at, populates field for existing papers on a best-effort
# basis.
class AddStateUpdatedAtToPaper < ActiveRecord::Migration
  # Faux paper class. Ensures this migration works and is unbound from
  # future changes.
  class Paper < ActiveRecord::Base
  end

  def up
    add_column :papers, :state_updated_at, :datetime
    Paper.reset_column_information

    ActiveRecord::Base.record_timestamps = false
    begin
      Paper.all.each do |paper|
        publishing_state = paper.publishing_state
        # Break for states we know about, but don't care to update. Continue
        # for unknown states.
        break unless states.fetch(publishing_state, true)
        # If the publishing state is unknown to us, use updated_at as a
        # best-effort case.
        field_to_copy_from = states.fetch(publishing_state, :updated_at)
        paper.update_attributes(
          state_updated_at: paper.send(field_to_copy_from))
      end
    ensure
      ActiveRecord::Base.record_timestamps = true
    end
  end

  def down
    remove_column :papers, :state_updated_at, :datetime
  end

  private

  def states
    # For this 'states' Hash, the key is the current publishing state, the
    # value is where we get the datetime to copy into state_updated_at
    {
      "unsubmitted" => nil,
      "initially_submitted" => :first_submitted_at,
      "invited_for_full_submission" => :updated_at,
      "submitted" => :submitted_at,
      "checking" => :updated_at,
      "in_revision" => :updated_at,
      "accepted" => :accepted_at,
      "rejected" => :updated_at,
      "published" => :published_at,
      "withdrawn" => :updated_at
    }
  end
end
