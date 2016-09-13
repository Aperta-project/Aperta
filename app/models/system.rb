class System < ActiveRecord::Base

  has_many :_journals, class_name: "Journal"

  def journals
    _journals.unscoped
  end

end
