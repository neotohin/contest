ActiveAdmin.register Superjudge do

  permit_params :list, :of, :attributes, :on, :model, :name, :email, :sent_mail, :sent_mail_time

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

    column :name do |superjudge|
      link_to superjudge.name, admin_superjudge_path(superjudge.id)
    end

    column "E-Mail Address", :email
    column :sent_mail
    column :sent_mail_time

    column "# Categories" do |superjudge|
      superjudge.categories.count
    end

    column "# Articles" do |superjudge|
      superjudge.all_articles.count
    end

    actions :defaults => false do |superjudge|
      link_to "Send Mail", send_mail_admin_superjudge_path(superjudge), class: "member_link"
    end
  end

  member_action :send_mail, :method => :get do
    resource.send_mail!
    redirect_to resource_path, notice: "Mail Sent!"
  end

  controller do
    def send_mail
      set_superjudge
      Timeout::timeout(10) do
        JudgeMailer.voting_notification(*set_mail_to_people, @superjudge).deliver_now
      end
      if Setting.first.mail_option
        @superjudge.update_attributes(:sent_mail => true, :sent_mail_time => Time.now)
        @superjudge.save
      end
      redirect_to admin_superjudges_path
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
        superjudge.all_articles.count
      end

      row "# Categories" do
        superjudge.categories.count
      end
    end

    panel "Categories for this Superjudge" do
      table_for(superjudge.categories.sort_by(&:code)) do |category|
        category.column("Code")  { |item| item.code }
        category.column("Name")  { |item| link_to item.name, admin_category_path(item.id) }
        category.column("Number of Articles")   { |item| item.articles.where(:category => category).count }
      end
    end

    panel "Articles for this Superjudge" do
      table_for(superjudge.all_articles.sort_by { |a| a[:article].code}) do |article_info|
        article_info.column("Status") do |item|
          if item[:article].a_first_choice_article?
            status_tag "First Choice", :style => "background: blue"
          elsif item[:article].a_second_choice_article?
            status_tag "Second Choice", :style => "background: red"
          else
            ""
          end
        end
        article_info.column("Code") { |item| item[:article].code }
        article_info.column("Title") { |item| link_to item[:article].pretty_title, admin_article_path(item[:article].id)  }
        article_info.column("Comment") { |item| item[:comment] }
      end
    end
  end

  form do |f|
    inputs 'Details' do
      f.input :name
      f.input :email
    end
    f.actions
  end

end

private

def set_superjudge
  @superjudge = Superjudge.find(params[:id])
end

def set_mail_to_people
  if Setting.first.mail_option
    [@superjudge.name, @superjudge.email]
  else
    [Setting.first.default_person, Setting.first.default_email]
  end
end

