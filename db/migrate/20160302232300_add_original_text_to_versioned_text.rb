##
# Creates a property to VersionedText to represent the original HTML returned
# by IHAT.
#
# The text property will now have further modifications, namely it will
# have figures inserted near their corresponding captions
class AddOriginalTextToVersionedText < ActiveRecord::Migration
  ##
  # Redundant definition to make this migration work in a future which possibly
  # doesn't include the definition of VersionedText
  class VersionedText < ActiveRecord::Base
    belongs_to :paper
    has_many :figures, through: :paper

    def insert_figures
      imageful_text = FigureInserter.new(original_text, figures).call
      self.text = imageful_text
    end
  end

  def up
    add_column :versioned_texts, :original_text, :text
    VersionedText.reset_column_information
    VersionedText.find_each do |v_text|
      v_text.original_text = v_text.text
      v_text.insert_figures
      v_text.save!
    end
  end

  def down
    VersionedText.reset_column_information
    VersionedText.find_each do |v_text|
      v_text.update!(text: v_text.original_text)
    end
    remove_column :versioned_texts, :original_text
  end
end
