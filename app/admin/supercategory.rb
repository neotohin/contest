ActiveAdmin.register Supercategory do

  permit_params :list, :of, :attributes, :on, :model, :letter_code, :display_name, :instructions

  menu :priority => 3

  sidebar :status, :priority => 0 do
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

  filter :display_name
  filter :letter_code
  filter :instructions
  filter :categories

  index do
    column :letter_code do |supercategory|
      link_to supercategory.letter_code, admin_supercategory_path(supercategory.id)
    end

    column :display_name do |supercategory|
      link_to supercategory.display_name, admin_supercategory_path(supercategory.id)
    end

    column("Categories") { |item| item.categories.count }
  end

  show do
    attributes_table do
      row :letter_code
      row :display_name
      row :instructions

      row "# Categories" do
        supercategory.categories.count
      end
    end

    panel "Categories For This Supercategory" do
      table_for(supercategory.categories) do |category|
        category.column("Code")  { |item| item.code }
        category.column("Name")  { |item| link_to item.name, admin_category_path(item.id) }
        category.column("Number of Articles")   { |item| item.articles.count }
      end
    end
  end

  form do |f|
    inputs "Details" do
      f.input :display_name
      f.input :letter_code
      f.input :instructions
      f.actions
    end
  end
end
