module ApplicationHelper
  def report_choice_tags(choices)
    if choices == 1
      status_tag :use_top_choice
    elsif choices == 2
      status_tag :use_top_two_choices
    elsif choices == 3
      status_tag :use_top_three_choices
    else
      status_tag :invalid
    end
  end
  
  def show_prize_level(article)
    if article.a_first_choice_article?
      status_tag :first_choice, :style => "background: blue"
    elsif article.a_second_choice_article?
      status_tag :second_choice, :style => "background: red"
    elsif article.a_third_choice_article?
      status_tag :third_choice, :style => "background: gold"
    else
      status_tag :not_chosen
    end
  end
end
