class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
    	t.integer :index
      t.string :name
      t.string :code
      t.string :instructions

      t.timestamps null: false
    end
    add_index :areas, :code

    create_table :mappings do |t|
      t.belongs_to :area, index: true
      t.belongs_to :judge, index: true

      t.integer :weight

      t.timestamps null: false
    end
  end
end
