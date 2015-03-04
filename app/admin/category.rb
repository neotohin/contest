include ApplicationHelper

ActiveAdmin.register Category do

  permit_params :list, :of, :attributes, :on, :model, :name, :code, :url,
                :report_choices, :superjudge_id, :supercategory_id, :index

  menu :priority => 4

  sidebar :status, :priority => 0 do
    mail_option_status
  end

  filter :supercategory, :as => :select, :collection => Supercategory.all.sort_by(&:display_name)
  filter :judges, :as => :select, :collection => Judge.all.sort_by(&:name)
  filter :name
  filter :code
  filter :report_choices

  index do
    column :code

    column :name do |category|
      span link_to category.name, admin_category_path(category.id)
      span link_to "(URL)", category.url
    end

    column "# Articles" do |category|
      category.articles.count
    end

    column "# Judges" do |category|
      category.judges.count
    end

    column :superjudge do |category|
      superjudge = category.superjudge
      link_to superjudge.name, admin_superjudge_path(superjudge) if superjudge
    end

    column :report_choices do |category|
      report_choice_tags(category.report_choices)
    end
  end

  show do

    attributes_table do
      row :supercategory
      row :code
      row :name

      row :superjudge do
        superjudge = category.superjudge
        link_to superjudge.name, admin_superjudge_path(superjudge) if superjudge
      end

      row "# Judges" do
        category.judges.count
      end

      row "# Articles" do
        category.articles.count
      end

      row :report_choices do
        report_choice_tags(category.report_choices)
      end

      row :url do
        link_to category.url, category.url
      end
    end

    panel "Judges for Category #{resource.code} - #{resource.name}" do
      table_for(category.judges.sort_by(&:name)) do |judge|
        judge.column("Judge") { |item| link_to item.name, admin_judge_path(item.id) }
        judge.column("Number of Articles") { |item| item.articles.where(:category => category).count }
        judge.column("Sent Mail") { |item| status_tag item.sent_mail ? "Yes" : "No" }
        judge.column("Voted?") { |item| status_tag item.votes_in? }
        judge.column("Weight") { |item| item.mappings.where(:category => category).first.weight }
      end
    end
    panel "Articles for Category #{resource.code} - #{resource.name}" do
      table_for(category.articles.sort_by(&:code)) do |document|
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
        document.column("Judge") { |item| item.judge.name }
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
      f.input :url
    end
    f.actions
  end

end
