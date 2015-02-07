class JudgeMailer < ApplicationMailer

  default :from => %("#{Setting.first.default_person}" <#{Setting.first.default_email}>)

  add_template_helper(ApplicationHelper)

  def contest_notification(to_name, to_email, judge)
    @judge = judge
    @details = judge.articles.group_by do |document|
      /([A-Z]{1,2})/.match(document.code)[1]
    end

    mail(:to => %("#{to_name}" <#{to_email}>), :subject => Setting.first.email_subject)
  end

  helper_method :get_major, :get_instructions, :get_first_name

  def get_major(code)
    Supercategory::SUPER_CATEGORIES[code]
  end

  def get_instructions(code)
    Supercategory.where(:letter_code => code).first.instructions
  end

  def get_first_name(name)
    words = name.split(" ")
    words.pop
    words.join(" ")
  end

end
