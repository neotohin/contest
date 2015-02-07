class Article < ActiveRecord::Base
	belongs_to :judge
  belongs_to :category

  # CATEGORY_LETTERS = "(#{Setting.first.category_prefix})"
  CATEGORY_LETTERS = "(SI|F|S|R|I)"
  REGEX     = "^#\\d+e?\\s(#{CATEGORY_LETTERS}\\.\\d+\\.\\d+)\\s+--\\s+(.*)\\s+--.*"
  LAX_REGEX = "^#\\d+e?\\s(#{CATEGORY_LETTERS}\\.\\d+\\.\\d+)\\s+--\\s+(.*)"
  SI_REGEX  = "^#\\d+e?\\s((SI)\\.\\d+\\.\\d+)\\s+--\\s+(.*)\\.docx"

  def pretty_title
    return regex[3] if article_regex
    self.title
  end

  def code
    return regex[1] if article_regex
    ""
  end

  def judge
    Judge.find(self.judge_id)
  end

  def category
    Category.find(self.category_id)
  end

  private

  attr_reader :regex

  def article_regex
    return @regex if @regex
    @regex = /#{REGEX}/.match(self.title) || /#{SI_REGEX}/.match(self.title) || /#{LAX_REGEX}/.match(self.title)
  end
end