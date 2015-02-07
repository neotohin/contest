class AddLetterCodeToSupercategory < ActiveRecord::Migration
  def change
    add_column :supercategories, :letter_code, :string
  end
end
