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

# This controller is responsible for returning all custom Cards
# that are available on a particular Paper's Journal.
#
# This is useful on the paper workflow page where it is necessary
# to ask, "what are all the custom cards available to be added
# to this particular paper's workflow?"  These tasks may or may
# not have been added to the Paper when it was created.
#
# In addition, make sure that the user has the proper permissions
# to receive this data.  Permissions are checked against the Paper
# even though the resources returned are part of the Journal.
#
class AvailableCardsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:manage_workflow, paper)
    respond_with paper.journal.active_cards, root: "cards", include_content: false
  end

  private

  def paper
    @paper ||= Paper.find_by_id_or_short_doi(params[:paper_id])
  end
end
