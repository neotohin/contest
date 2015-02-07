class RenameDocumentsTableToArticles < ActiveRecord::Migration
  def change
    rename_table :documents, :articles
  end
end
