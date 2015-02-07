ActiveAdmin.register Category do

  permit_params :list, :of, :attributes, :on, :model, :name, :code, :instructions, :index

  menu :priority => 4

  sidebar :status, :priority => 0 do
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

  filter :articles, :label => "Articles"
  filter :judges
  filter :name
  filter :code
  filter :instructions

  index do
    column :code

    column :name do |category|
      link_to category.name, admin_category_path(category.id)
    end

    column "Article Count" do |category|
      category.articles.count
    end

    column "Judge Count" do |category|
      category.judges.count
    end
  end

  show do

    attributes_table do
      row :supercategory
      row :code
      row :name

      row "# Judges" do
        category.judges.count
      end

      row "# Articles" do
        category.articles.count
      end
    end

    panel "Judges for this Category" do
      table_for(category.judges) do |judge|
        judge.column("Judge") { |item| link_to item.name, admin_judge_path(item.id) }
        judge.column("Number of Articles") { |item| item.articles.where(:category => category).count }
        judge.column("Weight") { |item| item.mappings.where(:category => category).first.weight }
      end
    end

    panel "Articles for this Category" do
      table_for(category.articles) do |document|
        document.column("Code") { |item| item.code }
        document.column("Title") { |item| link_to item.pretty_title, admin_article_path(item.id) }
      end
    end

  end

end
