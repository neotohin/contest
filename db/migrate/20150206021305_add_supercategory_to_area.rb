class AddSupercategoryToArea < ActiveRecord::Migration
  def change
    add_reference :areas, :supercategory, index: true
    add_foreign_key :areas, :supercategories
  end
end
