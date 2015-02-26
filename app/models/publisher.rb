class Publisher < ActiveRecord::Base
  validates :publisher_email,
            :format => {
                :with => /\A[^@]+@[^@]+\.[^@]+\z/,
                :message => "only valid e-mail formats accepted"
            }

  def articles
    Article.where("TITLE LIKE ?", "#{self.code_number}%").all
  end

  def winning_articles
    self.articles.select(&:is_a_final_winner?)
  end
end
