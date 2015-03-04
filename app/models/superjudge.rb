class Superjudge < ActiveRecord::Base
  has_many :categories
  has_many :articles

  validates :name, :presence => true
  validates :email,
            :format   => {
                :with    => /\A[^@]+@[^@]+\.[^@]+\z/,
                :message => "only valid e-mail formats accepted"
            },
            :presence => true

  NUMBER_OF_WINNERS = 5

  def all_articles
    self.categories.map(&:voted_in_articles).flatten.compact
  end

  def articles_list_to_vote_for
    all_articles.select do |article_info|
      %w(MAIL WINNER_BY_CHOICE RUNNER_UP).include?(article_info[:article].final)
    end
  end

  def articles_to_vote_for
    articles_list_to_vote_for.map do |article_info|
      article_info[:article]
    end
  end

  def votes_in?
    return "No" unless all_articles.any? { |article_info| article_info[:article].is_a_final_article? }
    all_articles.any? { |article_info| article_info[:article].final == "MAIL" } ? "No" : "Yes"
  end


  def calculate_judge_mailings(options = {})
    articles_to_consider = self.all_articles

    unless options[:force_recalculation]
      has_not_been_calculated = articles_to_consider.all? do |article_info|
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
    end

    # Reset final status for all of this superjudge's articles regardless of
    # their phase 1 status in case a previously chosen phase 1 article was
    # unchosen.
    self.articles.reject(&:any_choice_article?).each do |article|
      article.update_attributes({ :final => nil })
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
          article_info[:article].final      = "WINNER"
          article_info[:article].superjudge = self
          article_info[:article].save
        end
      elsif articles_by_level[NUMBER_OF_WINNERS - 1][:award_level] != articles_by_level[NUMBER_OF_WINNERS][:award_level]
        articles_by_level.each_with_index do |article_info, index|
          article_info[:article].final      = "WINNER" if index < NUMBER_OF_WINNERS
          article_info[:article].final      = nil if index >= NUMBER_OF_WINNERS
          article_info[:article].superjudge = self
          article_info[:article].save
        end
      else
        needs_judging_level = articles_by_level[NUMBER_OF_WINNERS - 1][:award_level]
        articles_by_level.each do |article_info|
          article_info[:article].final      = "WINNER" if article_info[:award_level] < needs_judging_level
          article_info[:article].final      = "MAIL" if article_info[:award_level] == needs_judging_level
          article_info[:article].final      = nil if article_info[:award_level] > needs_judging_level
          article_info[:article].superjudge = self
          article_info[:article].save
        end
      end
      articles_by_level
    end.flatten

  end
end
