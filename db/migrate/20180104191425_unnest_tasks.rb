# Remove all the old prefixes
class UnnestTasks < ActiveRecord::Migration
  PREFIXES = [
    "TahiStandardTasks::",
    "PlosBioTechCheck::",
    "Tahi::AssignTeam::",
    "PlosBioInternalReview::",
    "PlosBilling::"
  ].freeze

  def up
    PREFIXES.each do |prefix|
      execute "UPDATE tasks SET type = replace(type, '#{prefix}', '')"
    end
  end
end
