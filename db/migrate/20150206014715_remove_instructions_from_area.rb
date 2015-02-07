class RemoveInstructionsFromArea < ActiveRecord::Migration
  def change
    remove_column :areas, :instructions, :string
  end
end
