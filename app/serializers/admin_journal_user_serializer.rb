class AdminJournalUserSerializer < ActiveModel::Serializer
  attributes :id,
             :username,
             :first_name,
             :last_name

  has_many :user_roles, embed: :ids, include: true
  has_many :admin_journal_roles, embed: :ids, include: true

  def user_roles
    if @options[:journal].present?
      object.roles.where(journal: @options[:journal],
                         participates_in_papers: true,
                         participates_in_tasks: true)
    else
      object.roles.where(participates_in_papers: true,
                         participates_in_tasks: true)
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
