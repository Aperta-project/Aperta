class AnswerSerializer < ActiveModel::Serializer
  attributes :id,
    :value,
    :additional_data,
    :paper_id,
    :owner

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
