class CreatePublishers < ActiveRecord::Migration
  def change
    create_table :publishers do |t|
      t.string :name
      t.string :code_number

      t.timestamps null: false
    end
    add_index :publishers, :code_number
  end
end
