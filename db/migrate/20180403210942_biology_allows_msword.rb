class BiologyAllowsMsword < ActiveRecord::Migration
  def change
    journal = Journal.find_by(name: "PLOS Biology")
    return unless journal

    # rubocop:disable Rails/SkipsModelValidations
    journal.update_column(:msword_allowed, true)
    # rubocop:enable Rails/SkipsModelValidations
    raise unless Journal.find_by(name: "PLOS Biology").reload.msword_allowed?
  end
end
