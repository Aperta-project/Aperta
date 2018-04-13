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

require 'rails_helper'

describe "routes for assignments" do
  it "routes /api/assignments to the index action in assignments controller" do
    expect({ get: '/api/assignments', format: :json }).to route_to controller: "assignments",
      action: "index"
  end

  it "routes /api/assignments to the create action in assignments controller" do
    expect({ post: '/api/assignments', format: :json }).to route_to controller: "assignments",
      action: "create"
  end

  it "routes /api/assignments/1 to the destroy action in assignments controller" do
    expect({ delete: '/api/assignments/:id', format: :json }).to route_to controller: "assignments",
      action: "destroy", id: ":id"
  end
end
