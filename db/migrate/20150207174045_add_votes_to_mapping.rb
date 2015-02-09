class AddVotesToMapping < ActiveRecord::Migration
  def change
    add_column :mappings, :first_choice, :integer
    add_index  :mappings, :first_choice
    add_column :mappings, :second_choice, :integer
    add_index  :mappings, :second_choice
    add_column :mappings, :first_choice_comment, :string
    add_column :mappings, :second_choice_comment, :string
  end
end
