ActiveAdmin.register Judge do

  permit_params :list, :of, :attributes, :on, :model, :name, :email, :index,
                :sent_mail, :sent_mail_time, :new_category_id, :submit

  menu :priority => 7

  scope("All") { |scope| scope.all }
  scope("Mail Sent") { |scope| scope.where(:sent_mail => true) }
  scope("Mail Not Sent") { |scope| scope.where(:sent_mail => nil) }

  scope("Voted?") do |scope|
    Judge.where(:id => scope.select { |judge| judge.all_votes_in? == "Yes" }.map(&:id))
  end

  scope("Not Voted?") do |scope|
    Judge.where(:id => scope.select { |judge| judge.all_votes_in? == "No" }.map(&:id))
  end

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

    column "Voted?" do |judge|
      status_tag judge.all_votes_in?
    end

    actions :defaults => false do |judge|
      link_to "Send Mail", send_mail_admin_judge_path(judge), class: "member_link"
    end

    actions :defaults => false do |judge|
      link_to "Vote", vote_admin_judge_path(judge), class: "member_link"
    end
  end

  member_action :send_mail, :method => :get do
    resource.send_mail!
    redirect_to resource_path, notice: "Mail Sent!"
  end

  member_action :vote, :method => :get do
    @judge = resource
    redirect_to vote_admin_judge_path(@judge)
  end

  member_action :record_vote, :method => :post do

  end

  member_action :add_category, :method => [:get, :post] do
    @judge = resource
    if request.post?
      if params[:commit] == "cancel"
        redirect_to admin_judge_path(@judge)
        return
      end
      m             = Mapping.new
      m.judge_id    = @judge.id
      m.category_id = params[:new_category_id]
      if m.save
        redirect_to admin_judge_path(@judge)
        return
      else
        flash[:error] = "New category not saved"
        redirect_to add_category_admin_judge_path(@judge)
      end
    else
      @categories = (Category.all.to_a - @judge.categories.to_a).sort_by(&:code)
    end
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

    def vote
      set_judge
      @details = @judge.articles.group_by(&:category)
      @m = {}
      @details.each do |category, articles|
        m = category.mappings.where(:judge_id => @judge.id).first
        @m.merge!({ category.name  => {} })
        @m[category.name].merge!({ :first_choice => m.first_choice })
        @m[category.name].merge!({ :first_choice_comment => m.first_choice_comment })
        @m[category.name].merge!({ :second_choice => m.second_choice })
        @m[category.name].merge!({ :second_choice_comment => m.second_choice_comment })
      end
    end

    def record_vote
      if params[:commit] == "cancel"
        redirect_to admin_judges_path
        return
      end

      set_judge
      failure = false

      @judge.categories.each do |category|
        m                      = category.mappings.where(:judge_id => @judge.id).first
        m.first_choice         = params[:first_choice][category.id.to_s]
        m.first_choice_comment = (params[:first_choice_comment] || {})[category.id.to_s]
        if category.report_choices == 2
          m.second_choice         = params[:second_choice][category.id.to_s]
          m.second_choice_comment = (params[:second_choice_comment] || {})[category.id.to_s]
        else
          m.second_choice         = nil
          m.second_choice_comment = ""
        end

        failure = true unless m.valid?
        m.save
      end

      if failure
        flash[:error] = "First and second choices must not be the same for a given category"
        redirect_to vote_admin_judge_path(@judge)
        return
      end

      redirect_to admin_judge_path(@judge)
    end
  end

  action_item :add_category, :only => :show do
    link_to "Add Category", add_category_admin_judge_path(resource)
  end

  show do
    attributes_table do
      row :name
      row :email

      row :sent_mail do
        status_tag(:sent_mail)
      end

      row :sent_mail_time
      row :all_votes_in? do
        judge.all_votes_in?
      end

      row "# Articles" do
        judge.articles.count
      end

      row "# Categories" do
        judge.categories.count
      end
    end

    panel "Categories for this Judge" do
      table_for(judge.categories.sort_by(&:code)) do |category|
        category.column("Code") { |item| item.code }
        category.column("Name") { |item| link_to item.name, admin_category_path(item.id) }
        category.column("Number of Articles") { |item| item.articles.where(:judge => judge).count }
        category.column("Weight") { |item| item.mappings.where(:judge => judge).first.weight }
      end
    end

    panel "Articles for this Judge" do
      table_for(judge.articles.sort_by(&:code)) do |document|
        document.column("Status") do |item|
          if item.is_first_choice_article?(judge.id, item.category.id)
            status_tag "First Choice", :style => "background: blue"
          elsif item.is_second_choice_article?(judge.id, item.category.id)
            status_tag "Second Choice", :style => "background: red"
          else
            ""
          end
        end
        document.column("Code") { |item| item.code }
        document.column("Title") { |item| link_to item.pretty_title, admin_article_path(item.id) }
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


