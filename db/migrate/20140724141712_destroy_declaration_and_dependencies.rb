class DestroyDeclarationAndDependencies < ActiveRecord::Migration
  def up
    drop_table :declaration_surveys
    Task.where(type: "Declaration::Task").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
