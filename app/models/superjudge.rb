class Superjudge < ActiveRecord::Base
  has_many :categories

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

end
