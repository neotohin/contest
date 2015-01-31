ActiveAdmin.register Document, :as => "Article" do

  permit_params :list, :of, :attributes, :on, :model, :title, :link, :index


  index do
    column :code do |article|
      link_to article.code, admin_category_path(article.area_id)
    end

    column :category do |article|
      category_id = article.area_id
      link_to Area.find(category_id).name, admin_category_path(category_id)
    end

    column :article do |article|
      link_to article.pretty_title, admin_article_path(article.id)
    end

    column :judge do |article|
      judge_id = article.judge_id
      judge    = Judge.find(judge_id) if judge_id
      link_to judge.name, admin_judge_path(judge.id) if judge
    end

  end

  show :title => :pretty_title do
    attributes_table do
      row :code

      row :category do |article|
        category_id = article.area_id
        c = Area.find(category_id) if category_id
        link_to c.name, admin_category_path(category_id) if c
      end

      row :pretty_title

      row :raw_title do |article|
          article.title
      end

      row :link

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
