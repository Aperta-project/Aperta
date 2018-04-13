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

class AssocExisitingUserFlowToRoleFlow < ActiveRecord::Migration
  class RoleFlow < ActiveRecord::Base
    belongs_to :role, inverse_of: :role_flows
    has_one :journal, through: :role
    has_many :user_flows
    serialize :query, Array
  end

  class UserFlow < ActiveRecord::Base
    attr_accessor :papers
    belongs_to :user, inverse_of: :user_flows
    belongs_to :role_flow, inverse_of: :user_flows
  end

  def up
    UserFlow.all.each do |user_flow|
      role_flow = RoleFlow.find_by_title(user_flow.title)
      user_flow.update(role_flow_id: role_flow.id) if role_flow
    end

    remove_column :user_flows, :title
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
