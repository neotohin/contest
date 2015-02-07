class AddInstructionsToArea < ActiveRecord::Migration
  def change
    add_column :areas, :instructions, :string
  end
end
