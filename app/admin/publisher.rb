ActiveAdmin.register Publisher do

  permit_params :list, :of, :attributes, :on, :model, :name, :code_number,
                :publisher_contact, :publisher_email, :sent_mail, :sent_mail_time

  menu :priority => 8

  scope("All") { |scope| scope.all }
  scope("Mail Sent") { |scope| scope.where(:sent_mail => true) }
  scope("Mail Not Sent") { |scope| scope.where(:sent_mail => nil) }

  sidebar :status, :priority => 0 do
    mail_option_status
  end

  index do
    column :name do |pub|
      link_to pub.name, admin_publisher_path(pub)
    end

    column "Code #" do |pub|
      pub.code_number
    end

    column :publisher_contact
    column :publisher_email
    column :sent_mail
    column :sent_mail_time

    column "# Articles" do |pub|
      pub.articles.count
    end

    column "# Phase 1 Chosen" do |pub|
      pub.articles.select(&:any_choice_article?).count
    end

    column "# Winners" do |pub|
      pub.winning_articles.count
    end

    actions :defaults => false do |pub|
      link_to "Send Mail", send_mail_admin_publisher_path(pub), class: "member_link"
    end

  end

  member_action :send_mail, :method => :get do
    @publisher = resource
    @publisher.send_mail!
  end

  controller do
    def send_mail
      set_publisher
      if @publisher.winning_articles.count < 1
        flash[:error] = "No winning articles exist for #{@publisher.name}"
      else
        Timeout::timeout(60) do
          PublisherMailer.publisher_notification(*set_mail_to_publisher, @publisher).deliver_now
        end
        if Setting.first.mail_option
          @publisher.update_attributes(:sent_mail => true, :sent_mail_time => Time.now)
          @publisher.save
        end
        flash[:notice] = "Mail Sent Successfully!"
      end
    rescue
      flash[:error] = "Mail NOT Sent Successfully!"
    ensure
      redirect_to admin_publishers_path
    end

  end

  action_item :mail, :only => :show do
    link_to "Send Mail", send_mail_admin_publisher_path(resource)
  end

  show do
    attributes_table do

      row :name
      row :code_number
      row :publisher_contact
      row :publisher_email

      row "# Articles" do |pub|
        all_articles.count { |a| a.publisher_number == pub.code_number }
      end

      row "# First Choices" do |pub|
        first_choice_articles.count { |a| a.publisher_number == pub.code_number }
      end

      row "# Second Choices" do |pub|
        second_choice_articles.count { |a| a.publisher_number == pub.code_number }
      end

      row "# Third Choices" do |pub|
        third_choice_articles.count { |a| a.publisher_number == pub.code_number }
      end

      row "# Phase 1 Chosen" do |pub|
        pub.articles.select(&:any_choice_article?).count
      end

      row "# Winning Articles" do |pub|
        pub.winning_articles.count
      end
    end

    panel "Articles for Publisher #{resource.name}" do
      table_for(publisher.articles.sort_by(&:code)) do |document|
        document.column("Phase 1") do |item|
          show_prize_level(item)
        end

        document.column("Phase 2") do |item|
          show_final_level(item)
        end

        document.column("Code") { |item| item.code }
        document.column("Title") { |item|
          div do
            div link_to item.pretty_title, admin_article_path(item.id)
            if (m = item.any_choice_article?)
              div "Comment: #{m.comment_for(item.id)}", :style => "width: 600px;"
            end
          end
        }
        document.column("Publisher") { |item| item.publisher.name }
      end
    end
  end

  form do |f|
    inputs 'Details' do
      f.input :name
      f.input :code_number
      f.input :publisher_contact
      f.input :publisher_email
    end
    f.actions
  end

end

def all_articles
  @all_articles ||= Article.all.map
end

def first_choice_articles
  @first_choice_articles ||= Article.all.select { |a| a.a_first_choice_article? }
end

def second_choice_articles
  @second_choice_articles ||= Article.all.select { |a| a.a_second_choice_article? }
end

def third_choice_articles
  @third_choice_articles ||= Article.all.select { |a| a.a_third_choice_article? }
end

private

def set_publisher
  @publisher = Publisher.find(params[:id])
end

def set_mail_to_publisher
  if Setting.first.mail_option
    [@publisher.publisher_contact, @publisher.publisher_email]
  else
    [Setting.first.default_person, Setting.first.default_email]
  end
end