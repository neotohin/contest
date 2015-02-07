ActiveAdmin.register Judge do

  permit_params :list, :of, :attributes, :on, :model, :name, :email, :index, :sent_mail, :sent_mail_time

  menu :priority => 6

  scope("All") {|scope| scope.all}
  scope("Mail Sent") { |scope| scope.where(:sent_mail => true) }
  scope("Mail Not Sent") { |scope| scope.where(:sent_mail => nil) }

  sidebar :status, :priority => 0 do
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

  filter :articles
  filter :categories
  filter :name
  filter :email
  filter :sent_mail
  filter :sent_mail_time

  index do

    column :name do |judge|
      link_to judge.name, admin_judge_path(judge.id)
    end

    column "E-Mail Address", :email
    column :sent_mail
    column :sent_mail_time

    column "# Categories" do |judge|
      judge.categories.count
    end

    column "# Articles" do |judge|
      judge.articles.count
    end

    actions :defaults => false do |judge|
      link_to "Send Mail", send_mail_admin_judge_path(judge), class: "member_link"
    end
  end

  member_action :send_mail, :method => :get do
    resource.send_mail!
    redirect_to resource_path, notice: "Mail Sent!"
  end

  controller do
    def send_mail
      set_judge
      Timeout::timeout(10) do
        JudgeMailer.contest_notification(*set_mail_to_people, @judge).deliver_now
      end
      if Setting.first.mail_option
        @judge.update_attributes(:sent_mail => true, :sent_mail_time => Time.now)
        @judge.save
      end
      redirect_to admin_judges_path
    end
  end

  show do

    attributes_table do
      row :name
      row :email

      row :sent_mail do
        status_tag(:sent_mail)
      end

      row :sent_mail_time

      row "# Articles" do
        judge.articles.count
      end

      row "# Categories" do
        judge.categories.count
      end
    end

    panel "Categories for this Judge" do
      table_for(judge.categories) do |category|
        category.column("Code")  { |item| item.code }
        category.column("Name")  { |item| link_to item.name, admin_category_path(item.id) }
        category.column("Number of Articles")   { |item| item.articles.where(:judge => judge).count }
        category.column("Weight") { |item| item.mappings.where(:judge => judge).first.weight }
      end
    end

    panel "Articles for this Judge" do
      table_for(judge.articles) do |document|
        document.column("Code") { |item| item.code }
        document.column("Title") { |item| link_to item.pretty_title, admin_article_path(item.id) }
      end
    end
  end

end

private

def set_judge
  @judge = Judge.find(params[:id])
end

def set_mail_to_people
  if Setting.first.mail_option
    [@judge.name, @judge.email]
  else
    [Setting.first.default_person, Setting.first.default_email]
  end
end
