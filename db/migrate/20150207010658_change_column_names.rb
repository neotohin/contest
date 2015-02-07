class ChangeColumnNames < ActiveRecord::Migration
  def change
    rename_column :articles, :area_id, :category_id
    rename_column :mappings, :area_id, :category_id
  end
end
