class Document < ActiveRecord::Base
	belongs_to :judge
  belongs_to :document

  # CATEGORY_LETTERS = "(#{Setting.first.category_prefix})"
  CATEGORY_LETTERS = "(SI|F|S|R|I)"
  REGEX = "^#\\d+e?\\s(#{CATEGORY_LETTERS}\\.\\d+\\.\\d+)\\s+--\\s+(.*)\\s+--.*"
  SI_REGEX = "^#\\d+e?\\s((SI)\\.\\d+\\.\\d+)\\s+--\\s+(.*)\\.docx"

  def pretty_title
    return regex[3] if document_regex
    self.title
  end

  def code
    return regex[1] if document_regex
    ""
  end

  def judge
    Judge.find(self.judge_id)
  end

  def area
    Area.find(self.area_id)
  end

  private

  attr_reader :regex

  def document_regex
    return @regex if @regex
    @regex = /#{REGEX}/.match(self.title) || /#{SI_REGEX}/.match(self.title)
  end
end
