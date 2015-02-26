class AddPublisherContactToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :publisher_contact, :string
    add_column :publishers, :publisher_email, :string
  end
end
