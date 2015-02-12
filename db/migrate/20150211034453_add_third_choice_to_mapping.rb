class AddThirdChoiceToMapping < ActiveRecord::Migration
  def change
    add_column :mappings, :third_choice, :integer
    add_index  :mappings, :third_choice

    add_column :mappings, :third_choice_comment, :string
  end
end
