class ChangePreprintCardText < ActiveRecord::Migration
  OLD_TEXT = "Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, uncheck the box below.".freeze
  NEW_TEXT = "Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, indicate your choice below.".freeze

  # Just to be extra safe, scope content edits to the existing Preprint Posting card
  def custom_preprint_content
    CardContent.joins(:card_version, :card).where(cards: { name: "Preprint Posting" })
  end

  def swap_text(previous_text, new_text)
    custom_preprint_content.where(text: previous_text).find_each do |content|
      content.update!(text: new_text)
    end
    raise "Update failed, previous text still exists" if custom_preprint_content.where(text: previous_text).exists?
  end

  def up
    swap_text OLD_TEXT, NEW_TEXT
  end

  def down
    swap_text NEW_TEXT, OLD_TEXT
  end
end
