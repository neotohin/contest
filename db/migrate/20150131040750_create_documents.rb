class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
    	t.belongs_to :judge, index:true
      t.belongs_to :area, index:true

      t.integer :index
      t.string :title
      t.string :link

      t.timestamps null: false
    end
  end
end
