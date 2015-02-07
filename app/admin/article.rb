ActiveAdmin.register Article, :as => "Article" do

  permit_params :list, :of, :attributes, :on, :model, :title, :link, :index

  menu :priority => 5

  scope("All") {|scope| scope.all}
  scope("Articles Assigned") { |scope| scope.where("JUDGE_ID IS NOT NULL") }
  scope("Articles Not Assigned") { |scope| scope.where("JUDGE_ID IS NULL") }

  sidebar :status, :priority => 0 do
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

  filter :judge
  filter :category
  filter :title, :label => "Article"

  index do
    column :code do |article|
      link_to article.code, admin_category_path(article.category_id)
    end

    column :category, sortable: 'categories.name' do |article|
      category_id = article.category_id
      link_to Category.find(category_id).name, admin_category_path(category_id)
    end

    column :article do |article|
      link_to article.pretty_title, admin_article_path(article.id)
    end

    column :judge, :sortable => 'judges.name' do |article|
      judge_id = article.judge_id
      judge    = Judge.find(judge_id) if judge_id
      link_to judge.name, admin_judge_path(judge.id) if judge
    end

  end

  controller do
    def scoped_collection
      super.includes :category, :judge # prevents N+1 queries to your database
    end
  end

  show :title => :pretty_title do
    attributes_table do
      row :code

      row :category do |article|
        category_id = article.category_id
        c = Category.find(category_id) if category_id
        link_to c.name, admin_category_path(category_id) if c
      end

      row :pretty_title

      row :raw_title do |article|
        article.title
      end

      row :link do |article|
        link_to article.link, article.link , :target => "_blank"
      end

      row :judge do |article|
        judge_id = article.judge_id
        j = Judge.find(judge_id) if judge_id
        link_to j.name, admin_judge_path(judge_id) if j
      end
    end
  end

  form do |f|
    inputs 'Details' do
      input :title
      input :link
      input :id
    end
    actions
  end

end