class Category < ActiveRecord::Base
  has_many :mappings
  has_many :judges, :through => :mappings
  has_many :articles, -> { order "title asc" }, :dependent => :destroy
  belongs_to :supercategory
  belongs_to :superjudges

  codes = Supercategory::SUPER_CATEGORIES.keys

  validates :name, :presence => true
  validates :code,
            :presence => true,
            :format   => {
                :with    => /\A(#{codes.join("|")})\.\d+\z/,
                :message => "only valid codes are #{codes.join(".&lt;x&gt;, ")}.&lt;x&gt;"
            }
  validates :report_choices,
            :allow_blank => true,
            :inclusion   => {
                :in => [1, 2, 3], :message => "must choose 1, 2 or 3"
            }

  def first_choice_articles
    self.mappings.select(&:first_choice).map do |m|
      {
          :award_level => 1,
          :article     => Article.find(m.first_choice),
          :comment     => m.first_choice_comment,
          :mail_to_sj  => "NO"
      }
    end
  end

  def second_choice_articles
    self.mappings.select(&:second_choice).map do |m|
      {
          :award_level => 2,
          :article     => Article.find(m.second_choice),
          :comment     => m.second_choice_comment,
          :mail_to_sj  => "NO"
      }
    end
  end

  def third_choice_articles
    self.mappings.select(&:third_choice).map do |m|
      {
          :award_level => 3,
          :article     => Article.find(m.third_choice),
          :comment     => m.third_choice_comment,
          :mail_to_sj  => "NO"
      }
    end
  end

  def voted_in_articles
    return first_choice_articles if self.report_choices == 1
    return first_choice_articles + second_choice_articles if self.report_choices == 2
    return first_choice_articles + second_choice_articles + third_choice_articles if self.report_choices == 3
    []
  end
end
