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

##
# A related article represents a link to another manuscript, which
# may or may not already be published. Sometimes, two articles should
# be published together, so one needs to be held to wait for the
# other. Other times, they are related, but not simultaneously
# published. Those relationships are one-way.
class RelatedArticle < ActiveRecord::Base
  include ViewableModel
  include CustomCastTypes

  belongs_to :paper

  attribute :linked_title, HtmlString.new
  attribute :additional_info, HtmlString.new
  # Columns available:
  #
  # linked_doi: the DOI of the related article
  #
  # linked_title: the title of the related article
  #
  # additional_info: a free text field
  #
  # send_manuscripts_together: bool, true if this manuscript should be
  # published at the same time as the related article
  #
  # send_link_to_apex: bool, true if the relationship should be sent
  # to Apex for publication
  #

  def user_can_view?(check_user)
    check_user.can? :edit_related_articles, paper
  end
end
