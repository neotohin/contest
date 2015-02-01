require 'csv'
require 'nokogiri'

# Fill settings table with info
Setting.destroy_all
Setting.new(
    :articles_home    => "http://www.bashkoff-family.com/edible/",
    :csv_basename     => "Judge mgmt.csv",
    :mail_option      => false,
    :default_email    => "bashki.edible@gmail.com",
    :default_person   => "Lara Bashkoff",
    :email_subject    => "Your Articles for Review",
    :category_letters => "SI-F-S-R-I"
).save



# First extract the judges from the second and third rows of the csv file

raw         = CSV.read("Judge mgmt.csv")
judge_names = raw[1]
3.times { judge_names.shift }
judge_names.compact!

judge_emails = raw[2]
3.times { judge_emails.shift }
judge_emails = judge_emails[0..judge_names.length - 1]

Judge.destroy_all

judge_names.each_with_index do |judge, index|
  Judge.new(:index => index, :name => judge, :email => judge_emails[index]).save
end

# Extract the categories (areas) from the csv file

# CATEGORY_LETTERS = "(#{Setting.first.category_prefix})"
CATEGORY_LETTERS = "(SI|F|S|R|I)"

Area.destroy_all

raw.select do |raw_row|
  /^#{CATEGORY_LETTERS}\.\d$/.match(raw_row.first)
end.each_with_index do |row, index|
  a = Area.new(:name => row[1], :code => row[0], :index => index)
  a.save

  3.times { row.shift }

  judges_for_category = []
  judge_names.each_with_index do |judge, index|
    if row[index]
      j = Judge.where(:name => judge).first
      judges_for_category << j
    end
  end

  a.judges << judges_for_category

end

# Get the article names from the server

# response = Curl.get(Setting.first.articles_home)
response = Curl.get("http://www.bashkoff-family.com/edible/")
puts response.body_str
html_dom = Nokogiri::HTML(response.body_str)

node_texts = []
node_links = []
index      = 0
html_dom.xpath("//li//a").map do |node|
  next unless m = /^\s#\d+e?\s(#{CATEGORY_LETTERS}\.\d)\.\d+\s+--/.match(node.content)
  node_texts << node.content.strip
  node_links << node.attribute("href")
  # puts node.content.strip
  # puts node.attribute("href")
  # puts m[1]
  d = Document.new(
      :index => index,
      :title => node.content.strip,
      :link  => node.attribute("href")
  )
  d.area_id = Area.where(:code => m[1]).first.id
  d.save
  index += 1
end

# Now assign articles to each judge for every category

Area.all.each do |area|
  judges    = area.judges.shuffle
  documents = area.documents.shuffle
  puts "IN CATEGORY #{area.name} -------------------------------------------------------------"
  puts "                         JUDGES (#{judges.count}): #{judges.map(&:name).join(", ")}"
  puts "                         DOCUMENTS (#{documents.count}): #{documents.map(&:index)}"
  judges.each_with_index do |judge, judge_index|
  puts "            ASSIGNING JUDGE #{judge.name} ARTICLES ..................."

    judge_documents = documents.select do |d|
      documents.index(d) % judges.length == judge_index
    end
    puts "            ARTICLES #{judge_documents.map(&:index)}"
    judge.documents << judge_documents
    judge.save
  end

end