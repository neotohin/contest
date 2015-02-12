include ApplicationHelper

ActiveAdmin.register Category do

  permit_params :list, :of, :attributes, :on, :model, :name, :code,
                :report_choices, :superjudge_id, :supercategory_id, :index

  menu :priority => 4

  sidebar :status, :priority => 0 do
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

  filter :supercategory
  filter :articles, :label => "Articles"
  filter :superjudge
  filter :judges
  filter :name
  filter :code
  filter :report_choices

  index do
    column :code

    column :name do |category|
      link_to category.name, admin_category_path(category.id)
    end

    column "# Articles" do |category|
      category.articles.count
    end

    column "# Judges" do |category|
      category.judges.count
    end

    column :superjudge

    column :report_choices do |category|
      report_choice_tags(category.report_choices)
    end
  end

  show do

    attributes_table do
      row :supercategory
      row :code
      row :name
      row :superjudge

      row "# Judges" do
        category.judges.count
      end

      row "# Articles" do
        category.articles.count
      end

      row :report_choices do
        report_choice_tags(category.report_choices)
      end
    end

    panel "Judges for this Category" do
      table_for(category.judges.sort_by(&:name)) do |judge|
        judge.column("Judge") { |item| link_to item.name, admin_judge_path(item.id) }
        judge.column("Number of Articles") { |item| item.articles.where(:category => category).count }
        judge.column("Weight") { |item| item.mappings.where(:category => category).first.weight }
      end
    end
    panel "Articles for this Category" do
      table_for(category.articles.sort_by(&:code)) do |document|
        document.column("Status") do |item|
          show_prize_level(item)
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
      end
    end

  end

  form do |f|
    inputs 'Details' do
      f.input :supercategory
      f.input :superjudge
      f.input :name
      f.input :code
      f.input :report_choices, :as => :select, :collection => [1, 2, 3]
    end
    f.actions
  end

end
