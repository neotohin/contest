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

  def all_votes_in?
    first_choices = self.mappings.map(&:first_choice)
    first_choices.count > 0 && first_choices.all?  ? "Yes" : "No"
  end

end
