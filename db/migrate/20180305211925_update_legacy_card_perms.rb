class UpdateLegacyCardPerms < DataMigration
  def up
    DataTransformation::UpdateLegacyCardPerms.new.call
  end
end
