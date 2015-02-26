class AddPublisherIdToArticle < ActiveRecord::Migration
  def change
    add_reference :articles, :publisher, index: true
    add_foreign_key :articles, :publishers
  end
end
