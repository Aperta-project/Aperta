class CorrespondenceSerializer < ActiveModel::Serializer
  attributes :id, :date, :subject, :recipient, :sender, :body

  def date
    object.updated_at
  end

  def recipient
    object.recipients
  end
end
