class CreateSuperjudges < ActiveRecord::Migration
  def change
    create_table :superjudges do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
