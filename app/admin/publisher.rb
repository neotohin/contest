ActiveAdmin.register Publisher do

  menu :priority => 8

  sidebar :status, :priority => 0 do
    mail_option_status
  end

  index do
    column :name
    column :code_number

    column "# Articles" do |pub|
      all_articles.count { |a| a.publisher_number == pub.code_number }
    end

    column "# First Choices" do |pub|
      first_choice_articles.count { |a| a.publisher_number == pub.code_number }
    end

    column "# Second Choices" do |pub|
      second_choice_articles.count { |a| a.publisher_number == pub.code_number }
    end

    column "# Third Choices" do |pub|
      third_choice_articles.count { |a| a.publisher_number == pub.code_number}
    end

  end

end

def all_articles
  @all_articles ||= Article.all.map
end

def first_choice_articles
  @first_choice_articles ||= Article.all.select { |a| a.a_first_choice_article? }
end

def second_choice_articles
  @second_choice_articles ||= Article.all.select { |a| a.a_second_choice_article? }
end

def third_choice_articles
  @third_choice_articles ||= Article.all.select { |a| a.a_third_choice_article? }
end
