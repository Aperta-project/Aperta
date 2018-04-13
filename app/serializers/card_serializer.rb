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

# The CardSerializer is only used in an admin context at the moment. All of the
# card content for the latest version of the given card is serialized down as a
# single nested structure
class CardSerializer < AuthzSerializer
  attributes :id, :name, :journal_id, :xml, :state, :addable, :workflow_only
  has_one :content, embed: :id
  has_many :card_versions, embed: :ids
  has_many :latest_contents, embed: :ids, include: true, root: :card_contents
  has_one :card_task_type, embed: :id, include: true

  def content
    object.content_root_for_version(:latest)
  end

  # include_*? is a method that we can define for a given attribute that will
  # cause the serializer to omit the attribute if the method returns true. See
  # https://github.com/rails-api/active_model_serializers/tree/0-8-stable#attributes
  def include_content?
    @options[:include_content] != false
  end

  def include_xml?
    @options[:include_content] != false
  end

  def state
    object.state.camelize(:lower)
  end

  def addable
    object.addable?
  end

  def workflow_only
    object.latest_card_version.workflow_display_only
  end

  def xml
    object.to_xml.chomp
  end

  def content
    object.content_root_for_version(:latest)
  end

  def latest_contents
    @latest_contents ||= object.content_root_for_version(:latest).preload_descendants
  end
end
