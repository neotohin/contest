class Judge < ActiveRecord::Base
	has_many :mappings
  has_many :categories, :through => :mappings
  has_many :articles, -> { order "title asc" }, :dependent => :destroy

  validates :name, :presence => true
  validates :email,
            :format => {
                      :with => /\A[^@]+@[^@]+\.[^@]+\z/,
                      :message => "only valid e-mail formats accepted"
            },
            :presence => true

  def votes_in?
    return "No" if self.articles.count < 1
    nonzero_categories = self.articles.group_by(&:category).select do |category, articles|
      articles.count > 0
    end

    nonzero_categories.all? do |category, articles|
      articles.any?(&:any_choice_article?)
    end ? "Yes" : "No"
  end

end
