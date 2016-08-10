class AdminJournalUserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name

  has_many :user_roles, embed: :ids, include: true
  has_many :admin_journal_roles, embed: :ids, include: true

  def user_roles
    if @options[:journal].present?
      @options[:journal].user_roles.where(user: object)
    else
      object.user_roles
    end
  end

  def admin_journal_roles
    if @options[:journal].present?
      object.roles.where(journal: @options[:journal],
                         participates_in_papers: false,
                         participates_in_tasks: false)
    else
      object.roles
    end
  end
end
