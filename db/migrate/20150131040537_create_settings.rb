class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :articles_home
      t.string :csv_basename
      t.boolean :mail_option
      t.string :default_email
      t.string :default_person
      t.string :email_subject
      t.string :category_letters

      t.timestamps null: false
    end
  end
end
