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

  module SuperJudgeExtras
    NUMBER_OF_WINNERS = 5

    def calculate_judge_mailings
      resource.all_articles.group_by do |article_info|
        article_info[:article].category
      end.map do |category, articles|
        articles_by_level = articles.sort_by do |article|
          article[:award_level]
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
          articles_by_level.each do |article|
            article[:mail_to_sj] = "WINNER"
          end
        elsif articles_by_level[NUMBER_OF_WINNERS - 1][:award_level] != articles_by_level[NUMBER_OF_WINNERS][:award_level]
          articles_by_level[0..NUMBER_OF_WINNERS - 1].each do |article|
            article[:mail_to_sj] = "WINNER"
          end
        else
          needs_judging_level = articles_by_level[NUMBER_OF_WINNERS - 1][:award_level]
          articles_by_level.each do |article|
            article[:mail_to_sj] = "WINNER" if article[:award_level] < needs_judging_level
            article[:mail_to_sj] = "MAIL" if article[:award_level] == needs_judging_level
          end
        end
        articles_by_level
      end.flatten

    end

# Of the number of mailed articles in a category, this is how many must be
# selected by the superjudge

    def must_choose_number(article_list, category)
      NUMBER_OF_WINNERS - article_list.select do |article_info|
        article_info[:article].category == category
      end.count do |article_info|
        article_info[:mail_to_sj] == "WINNER"
      end
    end
  end
end

