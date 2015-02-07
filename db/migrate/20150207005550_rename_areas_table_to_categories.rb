class RenameAreasTableToCategories < ActiveRecord::Migration
  def change
    rename_table :areas, :categories
  end
end
