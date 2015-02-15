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
    if article.final == "NO"
      ""
    elsif article.final == "MAIL"
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
    if article.final == "NO"
      "Not Considered"
    elsif article.final == "MAIL"
      "Pending"
    elsif article.final == "WINNER"
      "Winner"
    elsif article.final == "WINNER_BY_CHOICE"
      "Chosen Winner"
    elsif article.final == "RUNNER_UP"
      "Runner-up"
    else
      "--"
    end
  end

  def mail_option_status
    if Setting.first.mail_option
      div "Mailings are activated", :style => "color: red"
    else
      div "Mailings are not activated"
    end
  end

  module SuperJudgeExtras
    NUMBER_OF_WINNERS = 5

    def calculate_judge_mailings
      articles_to_consider =  resource.all_articles

      has_not_been_calculated =  articles_to_consider.all? do |article_info|
        article_info[:article].final.blank?
      end

      unless has_not_been_calculated
        return articles_to_consider.group_by do |article_info|
          article_info[:article].category
        end.map do |category, article_infos|
          articles_by_level = article_infos.sort_by do |article_info|
            article_info[:award_level]
          end
          articles_by_level
        end.flatten
      end

      articles_to_consider.group_by do |article_info|
        article_info[:article].category
      end.map do |category, article_infos|
        articles_by_level = article_infos.sort_by do |article_info|
          article_info[:award_level]
        end

        # Cases:
        # 1. We have 5 or fewer articles - all are winners
        # 2. We have more than 5 articles and all articles for a given choice
        #    level fall in a range <= 5 - the first 5 are winners
        # 3. We have more than 5 articles but a set of articles in one choice level
        #    has articles that are in the overall 5th and 6th positions in this
        #    category - all articles of a higher award level are winners, and the
        #    articles at this award level need to be mailed

        if articles_by_level.length <= NUMBER_OF_WINNERS
          articles_by_level.each do |article_info|
            article_info[:article].final = "WINNER"
            article_info[:article].save
          end
        elsif articles_by_level[NUMBER_OF_WINNERS - 1][:award_level] != articles_by_level[NUMBER_OF_WINNERS][:award_level]
          articles_by_level[0..NUMBER_OF_WINNERS - 1].each do |article_info|
            article_info[:article].final = "WINNER"
            article_info[:article].save
          end
        else
          needs_judging_level = articles_by_level[NUMBER_OF_WINNERS - 1][:award_level]
          articles_by_level.each do |article_info|
            article_info[:article].final = "WINNER" if article_info[:award_level] < needs_judging_level
            article_info[:article].final = "MAIL" if article_info[:award_level] == needs_judging_level
            article_info[:article].save
          end
        end
        articles_by_level
      end.flatten

    end

# Of the number of mailed articles in a category, this is how many must be
# selected by the superjudges

    def must_choose_number(article_list, category)
      NUMBER_OF_WINNERS - article_list.select do |article_info|
        article_info[:article].category == category
      end.count do |article_info|
        article_info[:article].final == "WINNER"
      end
    end
  end
end

