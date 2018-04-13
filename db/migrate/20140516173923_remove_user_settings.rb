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

unless defined? Flow
  class Flow < ActiveRecord::Base; end
end

unless defined? UserSettings
  class UserSettings < ActiveRecord::Base
    belongs_to :user
    has_many :flows
  end
end

class RemoveUserSettings < ActiveRecord::Migration
  def up
    add_column :flows, :user_id, :integer, index: true

    Flow.all.each do |flow|
      # this weirdness is due to poor relationships between Flow & UserSetting
      # which is one of the many reasons it is being removed
      user_id = UserSettings.find_by(id: flow.user_settings_id)
      flow.update_column(:user_id, user_id)
    end

    drop_table :user_settings
    remove_column :flows, :user_settings_id
  end

  def down
    remove_column :flows, :user_id
    add_column :flows, :user_settings_id, :integer
    create_table :user_settings do |t|
      t.references :user, index: true
      t.timestamps
    end
  end
end
