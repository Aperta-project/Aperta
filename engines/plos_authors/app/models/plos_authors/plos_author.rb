module PlosAuthors
  class PlosAuthor < ActiveRecord::Base
    acts_as :author, dependent: :destroy

    belongs_to :plos_authors_task, inverse_of: :plos_authors
  end
end
