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

  def show_prize_level_string(article)
    if article.a_first_choice_article?
      "First Choice"
    elsif article.a_second_choice_article?
      "Second Choice"
    elsif article.a_third_choice_article?
      "Third Choice"
    else
      "Not Chosen"
    end
  end

  def show_final_level(article)
    if article.final == "MAIL"
      status_tag :pending, :style => "background: blue;"
    elsif article.final == "WINNER"
      status_tag :winner, :style => "background: green;"
    elsif article.final == "WINNER_BY_CHOICE"
      status_tag :chosen_winner, :style => "background: green;"
    elsif article.final == "RUNNER_UP"
      status_tag :runner_up, :style => "background: purple;"
    else
      ""
    end
  end

  def show_final_level_string(article)
    if article.final == "MAIL"
      "Pending"
    elsif article.final == "WINNER"
      "Winner"
    elsif article.final == "WINNER_BY_CHOICE"
      "Chosen Winner"
    elsif article.final == "RUNNER_UP"
      "Runner-up"
    else
      "Not Considered"
    end
  end

  def mail_option_status
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

# Of the number of mailed articles in a category, this is how many must be
# selected by the superjudges

  def must_choose_number(article_list, category)
    Superjudge::NUMBER_OF_WINNERS - article_list.select do |article_info|
      article_info[:article].category == category
    end.count do |article_info|
      article_info[:article].final == "WINNER"
    end
  end
end

