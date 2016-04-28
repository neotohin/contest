require 'csv'
require 'nokogiri'

# Fill settings table with info
Setting.destroy_all
Setting.create(
    :articles_home    => 'https://s3.amazonaws.com/edible-2016-contest/',
    :csv_basename     => 'Entry distribution to judges tables.csv',
    :mail_option      => false,
    :default_email    => 'bashki.edible@gmail.com',
    :default_person   => 'Lara Bashkoff',
    :email_subject    => 'Your Articles for Review',
    :category_letters => Supercategory::SUPER_CATEGORIES.keys.join("-")
)

# Populate the supercategories table

Supercategory.destroy_all
Supercategory::SUPER_CATEGORIES.each do |letter_code, name|
  s = Supercategory.create(:letter_code => letter_code, :display_name => name)
end

# First extract the judges from the second and third rows of the csv file

raw         = CSV.read("Entry distribution to judges tables.csv")
judge_names = raw[1]
3.times { judge_names.shift }
judge_names.compact!

judge_emails = raw[2]
3.times { judge_emails.shift }
judge_emails = judge_emails[0..judge_names.length - 1]

Judge.destroy_all

judge_names.each_with_index do |judge, index|
  Judge.create(:index => index, :name => judge, :email => judge_emails[index])
end

# Extract the categories from the csv file

CATEGORY_LETTERS = "(#{Supercategory::SUPER_CATEGORIES.keys.join("|")})"

Category.destroy_all

raw.select do |raw_row|
  /^#{CATEGORY_LETTERS}\.\d$/.match(raw_row.first)
end.each_with_index do |row, index|
  a = Category.create(:name => row[1], :code => row[0], :index => index)
  category_letter = /\A#{CATEGORY_LETTERS}\./.match(a.code)[1]
  a.supercategory = Supercategory.where(:letter_code => category_letter).first
  a.save

  3.times { row.shift }

  judge_names.each_with_index do |judge, index|
    if row[index]
      j = Judge.where(:name => judge).first
      a.save && a.mappings.create(:judge => j, :weight => row[index].to_i)
    end
  end

end

# Get the article names from the server

s3 = AWS::S3.new
objects = s3.buckets["edible-2016-contest"].objects
objects.each_with_index do |obj, index|
  next unless m = /^#\d+e?\s(#{CATEGORY_LETTERS}\.\d)\.\d+\s+--/.match(obj.key)
  puts obj.key
  d = Article.create(
      :index => index.to_s,
      :title => obj.key.strip,
      :link  => obj.url_for(:read, :expires => "2016-03-23")
  )
  d.category_id = Category.where(:code => m[1]).first.id
  d.save
end

# Now assign articles to each judge for every category

Category.all.each do |category|
  judges_pool = category.judges.map do |judge|
    [judge] * judge.mappings.where(:category => category).first.weight
  end.flatten

  judges_pool.shuffle!
  articles = category.articles.shuffle
  puts "IN CATEGORY #{category.name} -------------------------------------------------------------"
  puts "                         JUDGES (#{judges_pool.count}): #{judges_pool.map(&:name).join(", ")}"
  puts "                         DOCUMENTS (#{articles.count}): #{articles.map(&:index)}"
  judges_pool.each_with_index do |judge, judge_index|
  puts "            ASSIGNING JUDGE #{judge.name} ARTICLES ..................."

    judge_articles = articles.select do |d|
      articles.index(d) % judges_pool.length == judge_index
    end
    puts "            ARTICLES #{judge_articles.map(&:index)}"
    judge.articles << judge_articles
    judge.save
  end

end
