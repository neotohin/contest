class AddMailToPublisher < ActiveRecord::Migration
  def change
    add_column :publishers, :sent_mail, :boolean
    add_column :publishers, :sent_mail_time, :datetime
  end
end
