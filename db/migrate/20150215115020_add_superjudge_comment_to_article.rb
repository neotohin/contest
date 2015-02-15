class AddSuperjudgeCommentToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :superjudge_comment, :string
  end
end
