class NestedQuestionAddRequired < ActiveRecord::Migration
  def change
    add_column :nested_questions, :ready_required_check, :string, default: nil, null: true
    add_column :nested_questions, :ready_children_check, :string, default: nil, null: true
    add_column :nested_questions, :ready_check, :string, default: nil, null: true
    reversible do |dir|
      dir.up do
        q = NestedQuestion
              .where(ident: 'competing_interests--statement')
              .first
        q.update!(
            ready_required_check: 'if_parent_yes',
            ready_check: 'long_string'
        )
        NestedQuestion
          .where(ident: 'competing_interests--has_competing_interests')
          .first.update!(
            ready_required_check: 'required'
          )
      end
    end
  end
end
