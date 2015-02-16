class Superjudge < ActiveRecord::Base
  has_many :categories
  has_many :articles

  validates :name, :presence => true
  validates :email,
            :format => {
                :with => /\A[^@]+@[^@]+\.[^@]+\z/,
                :message => "only valid e-mail formats accepted"
            },
            :presence => true

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

  def all_votes_in?
    return "No" unless all_articles.any? { |article_info| article_info[:article].is_a_final_article? }
    all_articles.any? { |article_info| article_info[:article].final == "MAIL" } ? "No" : "Yes"
  end

end
