class JudgeMailer < ApplicationMailer

  attr_reader :resource

  default :from => %("#{Setting.first.default_person}" <#{Setting.first.default_email}>)

  add_template_helper(ApplicationHelper)

  def judge_notification(to_name, to_email, judge)
    @judge   = judge
    @details = judge.articles.group_by do |document|
      /([A-Z]{1,2})/.match(document.code)[1]
    end

    mail(:to => %("#{to_name}" <#{to_email}>), :subject => Setting.first.email_subject)
  end

  def superjudge_notification(to_name, to_email, superjudge)
    @resource    = superjudge
    article_list = superjudge.calculate_judge_mailings

    @details     = article_list.select do |article_info|
      article_info[:article].final == "MAIL"
    end.group_by do |article_info|
      /([A-Z]{1,2})/.match(article_info[:article].code)[1]
    end

    @numbers_to_pick = article_list.group_by do |article_info|
      article_info[:article].category
    end.keys.reduce({}) do |m, category|
      m.merge({ category => must_choose_number(article_list, category) })
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
