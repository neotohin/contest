class AddFinalToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :final, :string
  end
end
