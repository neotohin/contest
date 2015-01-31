class CreateJudges < ActiveRecord::Migration
  def change
    create_table :judges do |t|
    	t.integer :index
      t.string :name
      t.string :email
      t.boolean :sent_mail
      t.datetime :sent_mail_time

      t.timestamps null: false
    end
    
    add_index :judges, :name
  end
end
