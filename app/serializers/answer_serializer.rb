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

class AnswerSerializer < AuthzSerializer
  include ReadySerializable
  attributes :id,
    :value,
    :annotation,
    :additional_data,
    :paper_id,
    :owner,
    :repetition_id

  has_one :card_content, embed: :id
  has_many :attachments, embed: :ids, include: true, root: :question_attachments

  def owner
    # Polymorphic assocations and STI do not play perfectly well with each other, as per
    # http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#label-Polymorphic+Associations
    # Our Tasks are an STI table, so object.owner_type is going to be 'Task' for a Task subclass,
    # but Ember expects to have a specific subclass.
    owner_instance = object.owner
    { id: owner_instance.id, type: owner_instance.class.name.demodulize }
  end
end
