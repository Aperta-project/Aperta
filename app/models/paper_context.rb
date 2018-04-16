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

class PaperContext < TemplateContext
  include UrlBuilder

  whitelist :title, :abstract, :paper_type
  subcontexts :academic_editors,      type: :user
  subcontexts :handling_editors,      type: :user
  subcontexts :authors,               type: :author
  subcontexts :corresponding_authors, type: :author
  subcontext  :editor,                type: :user
  subcontext  :creator,               type: :user

  def editor
    return if object.handling_editors.empty?
    UserContext.new(object.handling_editors.first)
  end

  def url
    url_for(:paper, id: object.id).sub("api/", "")
  end

  def creator
    UserContext.new(@object.creator)
  end

  def preprint_opted_in
    FeatureFlag[:PREPRINT] && @object.manuscript_manager_template.is_preprint_eligible && @object.preprint_opt_in?
  end

  def preprint_opted_out
    FeatureFlag[:PREPRINT] && @object.manuscript_manager_template.is_preprint_eligible && @object.preprint_opt_out?
  end
end
