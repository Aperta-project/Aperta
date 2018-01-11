class Aperta12318FixCardEditPermissionStates < ActiveRecord::Migration
  def change
    DataTransformation::FixPermissionStates.new.call
  end
end
