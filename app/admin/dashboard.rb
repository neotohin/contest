ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div do
      span class: "blank_slate" do
        h3 "Welcome to the Edible Communities Contest Application!"
        ul do
          if Setting.first.mail_option
            li "Mailings are activated"
          else
            li "Mailings are not activated"
            li "Mailings will be sent to #{Setting.first.default_person} at #{Setting.first.default_email}"
          end
        end
        div "Summary Information:"
        div do
          li "Total number of articles: #{number_articles} "
          li "Total number of articles without a judge: #{number_unassigned_articles} "
          li "Total number of judges: #{number_judges} "
          li "Total number of mailings sent: #{mailings_sent}"
          li "Total number of mailings not sent: #{mailings_not_sent}"
        end
      end
    end # content

  end

end

def number_articles
  Article .count
end

def number_judges
  Judge.count
end

def mailings_sent
  Judge.where(:sent_mail => true).count
end

def mailings_not_sent
  Judge.where("SENT_MAIL IS NULL").count
end

def number_unassigned_articles
  Article.where("JUDGE_ID IS NULL").count
end