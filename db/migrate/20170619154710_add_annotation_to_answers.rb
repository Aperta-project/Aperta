class AddAnnotationToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :annotation, :string
  end
end
