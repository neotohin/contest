class Mapping < ActiveRecord::Base
  belongs_to :category
  belongs_to :judge

  validate :choices_dont_match?

  def comment_for(article_id)
    return self.first_choice_comment if self.first_choice == article_id
    return self.second_choice_comment if self.second_choice == article_id
    return self.third_choice_comment if self.third_choice == article_id
    ""
  end

  def choices_dont_match?
    choices = [first_choice, second_choice, third_choice]

    return if choices.count(&:nil?) > 1

    a_pair_matches = choices.compact.combination(2).any? do |a|
      a.first == a.last
    end

    if a_pair_matches
      errors.add(:second_choice, "any two choices cannot be the same")
    end
  end

end