class AdminJournalUserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name

  has_many :user_roles, embed: :id, include: true

  def user_roles
    if @options[:journal].present?
      @options[:journal].user_roles.where(user: object)
    else
      object.user_roles
    end
  end
end
