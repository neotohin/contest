class Document < ActiveRecord::Base
	belongs_to :judge
  belongs_to :document

  # CATEGORY_LETTERS = "(#{Setting.first.category_prefix})"
  CATEGORY_LETTERS = "(SI|F|S|R|I)"
  REGEX = "^#\\d+[a-z]\\s(#{CATEGORY_LETTERS}\\.\\d+\\.\\d+)\\s+--\\s+(.*)"

  def pretty_title
    return regex[3] if document_regex
    self.title
  end

  def code
    return regex[1] if document_regex
    ""
  end

  private

  attr_reader :regex

  def document_regex
    @regex ||= /#{REGEX}/.match(self.title)
  end
end
