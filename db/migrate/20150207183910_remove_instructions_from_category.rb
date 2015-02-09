class RemoveInstructionsFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :instructions, :string
  end
end
