class Article < ActiveRecord::Base
  belongs_to :judge
  belongs_to :superjudge
  belongs_to :category
  belongs_to :publisher

  validates :title, :presence => true

  CATEGORY_LETTERS = "(SI|F|S|R|I|D)"
  REGEX            = "^(#\\d+e?)\\s(#{CATEGORY_LETTERS}\\.\\d+\\.\\d+)\\s+--\\s+(.*)\\s+--.*"
  LAX_REGEX        = "^(#\\d+e?)\\s(#{CATEGORY_LETTERS}\\.\\d+\\.\\d+)\\s+--\\s+(.*)"
  SI_REGEX         = "^(#\\d+e?)\\s((SI)\\.\\d+\\.\\d+)\\s+--\\s+(.*)\\.docx"

  def pretty_title
    return regex[4] if article_regex
    self.title
  end

  def code
    return regex[2] if article_regex
    ""
  end

  def publisher_number
    return regex[1] if article_regex
    ""
  end

  def judge
    Judge.find(self.judge_id)
  end

  def comment
    if (mapping = any_choice_article?)
      mapping.comment_for(self.id)
    else
      ""
    end
  end

  def any_choice_article?
    h = [self.id] * 3
    Mapping.where("first_choice = ? OR second_choice = ? OR third_choice = ?", *h).first
  end

  def a_first_choice_article?
    Mapping.where(:first_choice => self.id).present?
  end

  def a_second_choice_article?
    Mapping.where(:second_choice => self.id).present?
  end

  def a_third_choice_article?
    Mapping.where(:third_choice => self.id).present?
  end

  def is_first_choice_article?(judge_id, category_id)
    m = Mapping.where(:judge_id => judge_id, :category_id => category_id).first
    self.id == m.first_choice
  end

  def is_second_choice_article?(judge_id, category_id)
    m = Mapping.where(:judge_id => judge_id, :category_id => category_id).first
    self.id == m.second_choice
  end

  def is_third_choice_article?(judge_id, category_id)
    m = Mapping.where(:judge_id => judge_id, :category_id => category_id).first
    self.id == m.third_choice
  end

  def is_a_final_article?
    self.final == "WINNER" || self.final == "MAIL"
  end

  def is_a_final_winner?
    self.final == "WINNER" || self.final == "WINNER_BY_CHOICE"
  end

  attr_reader :regex

  def article_regex
    return @regex if @regex
    @regex = /#{REGEX}/.match(self.title) || /#{SI_REGEX}/.match(self.title) || /#{LAX_REGEX}/.match(self.title)
  end

end
