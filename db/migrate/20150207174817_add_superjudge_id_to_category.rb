class AddSuperjudgeIdToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :superjudge_id, :integer
    add_index  :categories, :superjudge_id
    add_column :categories, :report_choices, :integer
  end
end
