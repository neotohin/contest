ActiveAdmin.register Superjudge do

  permit_params :list, :of, :attributes, :on, :model, :name, :email, :sent_mail, :sent_mail_time

  menu :priority => 6

  scope("All") { |scope| scope.all }
  scope("Mail Sent") { |scope| scope.where(:sent_mail => true) }
  scope("Mail Not Sent") { |scope| scope.where(:sent_mail => nil) }

  sidebar :status, :only => :index, :priority => 0 do
    mail_option_status
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

    column "Voted?" do |superjudge|
      status_tag superjudge.all_votes_in?
    end

    actions :defaults => false do |superjudge|
      link_to "Send Mail", send_mail_admin_superjudge_path(superjudge), class: "member_link"
    end

    actions :defaults => false do |judge|
      link_to "Vote", vote_admin_superjudge_path(judge), class: "member_link"
    end
  end

  member_action :send_mail, :method => :get do
    resource.send_mail!
    redirect_to resource_path, notice: "Mail Sent!"
  end

  member_action :vote, :method => :get do
    @superjudge = resource
    @superjudge.vote!
  end

  member_action :record_vote, :method => :post do

  end

  controller do
    def vote
      set_superjudge
      if @superjudge.categories.count < 1 || @superjudge.articles_to_vote_for.count < 1
        flash[:error] = "#{@superjudge.name} either has no categories or no articles to vote for"
        redirect_to admin_superjudges_path
        return
      end
      @details = @superjudge.articles_to_vote_for.group_by(&:category)
      @m = {}
      @details.each do |category, articles|
        @m.merge!({ category.name => {} })
        articles.each do |article|
          @m[category.name].merge!({ :choice => article.id })
          @m[category.name].merge!({ :choice_comment => article.pretty_title })
        end
      end
    end

    def record_vote
      if params[:commit] == "cancel"
        redirect_to admin_superjudges_path
        return
      end

      set_superjudge
      failure = false

      @superjudge.categories.each do |category|
        m                      = category.mappings.where(:superjudge_id => @superjudge.id).first
        m.first_choice         = params[:first_choice][category.id.to_s]
        m.first_choice_comment = (params[:first_choice_comment] || {})[category.id.to_s]

        failure                = true unless m.valid?
        m.save
      end

      if failure
        flash[:error] = "Choices must not be the same for a given category"
        redirect_to vote_admin_superjudge_path(@superjudge)
        return
      end

      redirect_to admin_superjudge_path(@superjudge)
    end

    def send_mail
      set_superjudge
      Timeout::timeout(10) do
        JudgeMailer.superjudge_notification(*set_mail_to_people, @superjudge).deliver_now
      end
      if Setting.first.mail_option
        @superjudge.update_attributes(:sent_mail => true, :sent_mail_time => Time.now)
        @superjudge.save
      end
      redirect_to admin_superjudges_path
    end
  end

  action_item :mail, :only => :show do
    link_to "Send Mail", send_mail_admin_superjudge_path(resource)
  end

  action_item :vote, :only => :show do
    link_to "Vote", vote_admin_superjudge_path(resource)
  end

  show do
    panel "Mailings status" do
      mail_option_status
    end

    attributes_table do
      row :name
      row :email

      row :sent_mail do
        status_tag :sent_mail
      end

      row :sent_mail_time

      row :all_votes_in? do
        superjudge.all_votes_in?
      end

      row "# Categories" do
        superjudge.categories.count
      end

      row "# Articles" do
        superjudge.all_articles.count
      end
    end


    panel "Categories for this Superjudge" do
      table_for(superjudge.categories.sort_by(&:code)) do |category|
        category.column("Code") { |item| item.code }
        category.column("Name") { |item| link_to item.name, admin_category_path(item.id) }
        category.column("Number of Articles") { |item| item.articles.where(:category => category).count }
        category.column("Report Choices") { |item| report_choice_tags(item.report_choices) }
      end
    end

    panel "Articles Under Consideration for this Superjudge" do
      article_list = calculate_judge_mailings.sort_by do |a|
        a[:article].category.id.to_s + a[:award_level].to_s
      end
      table_for(article_list) do |article_info|
        article_info.column("Action") do |item|
          if item[:mail_to_sj] == "WINNER"
            status_tag :winner, :style => "background: green;"
          elsif item[:mail_to_sj] == "MAIL"
            status_tag :mail, :style => "background: blue;"
          else
            ""
          end
        end
        article_info.column("Status") do |item|
          show_prize_level(item[:article])
        end
        article_info.column("Code") { |item| item[:article].code }
        article_info.column("Title") { |item|
          div do
            div link_to item[:article].pretty_title, admin_article_path(item[:article].id)
            if (m = item[:article].any_choice_article?)
              div "Comment: #{m.comment_for(item[:article].id)}", :style => "width: 600px;"
            end
          end
        }
        article_info.column("Judge") do |item|
          link_to item[:article].judge.name, admin_judge_path(item[:article].judge)
        end
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

include ApplicationHelper::SuperJudgeExtras

