class AddMailItemsToSuperjudge < ActiveRecord::Migration
  def change
    add_column :superjudges, :sent_mail, :boolean
    add_column :superjudges, :sent_mail_time, :datetime
  end
end
