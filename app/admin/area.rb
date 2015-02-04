ActiveAdmin.register Area, :as => "Category" do

  permit_params :list, :of, :attributes, :on, :model, :name, :code, :instructions, :index

  preserve_default_filters!
  filter :documents, :label => "Articles"

  index do
    column :code

    column :name do |category|
      link_to category.name, admin_category_path(category.id)
    end

    column "Article Count" do |category|
      category.documents.count
    end

    column "Judge Count" do |category|
      category.judges.count
    end
  end

  show do

    attributes_table do
      row :code
      row :name
      row :instructions

      row "# Judges" do
        category.judges.count
      end

      row "# Articles" do
        category.documents.count
      end
    end

    panel "Judges for this Category" do
      table_for(category.judges) do |judge|
        judge.column("Judge") { |item| link_to item.name, admin_judge_path(item.id) }
        judge.column("Number of Articles") { |item| item.documents.where(:area => category).count }
        judge.column("Weight") { |item| item.mappings.where(:area => category).first.weight }
      end
    end

    panel "Articles for this Category" do
      table_for(category.documents) do |document|
        document.column("Code") { |item| item.code }
        document.column("Title") { |item| link_to item.pretty_title, admin_article_path(item.id) }
      end
    end

  end

end
