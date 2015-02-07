class CreateSupercategories < ActiveRecord::Migration
  def change
    create_table :supercategories do |t|
      t.string :display_name
      t.string :instructions

      t.timestamps null: false
    end
  end
end
