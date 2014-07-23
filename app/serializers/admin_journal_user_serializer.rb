class AdminJournalUserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name

  has_many :user_roles, embed: :id, include: true

  def user_roles
    if @options[:journal]
      @options[:journal].user_roles.where(user: object)
    else
      super
    end
  end
end
