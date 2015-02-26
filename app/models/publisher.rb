class Publisher < ActiveRecord::Base
  has_many :articles

  validates :publisher_email,
            :format => {
                :with => /\A[^@]+@[^@]+\.[^@]+\z/,
                :message => "only valid e-mail formats accepted"
            },
            :allow_nil => true

  def winning_articles
    self.articles.select(&:is_a_final_winner?)
  end
end
