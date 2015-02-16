class AddSuperjudgeIdToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :superjudge_id, :integer
    add_index :articles, :superjudge_id
  end
end
