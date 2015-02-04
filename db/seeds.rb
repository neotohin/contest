require 'csv'
require 'nokogiri'

# Fill settings table with info
Setting.destroy_all
Setting.new(
    :articles_home    => "https://s3.amazonaws.com/ediblecommunities/articles-2015/",
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

  judge_names.each_with_index do |judge, index|
    if row[index]
      j = Judge.where(:name => judge).first
      a.save && a.mappings.create(:judge => j, :weight => row[index].to_i)
    end
  end

end

# Get the article names from the server

s3 = AWS::S3.new
objects = s3.buckets["edible-2015-contest"].objects
objects.each_with_index do |obj, index|
  next unless m = /^#\d+e?\s(#{CATEGORY_LETTERS}\.\d)\.\d+\s+--/.match(obj.key)
  puts obj.key
  d = Document.new(:index => index.to_s, :title => obj.key.strip, :link  => obj.url_for(:read))
  d.area_id = Area.where(:code => m[1]).first.id
  d.save
end

# Now assign articles to each judge for every category

Area.all.each do |area|
  judges_pool = area.judges.map do |judge|
    [judge] * judge.mappings.where(:area => area).first.weight
  end.flatten

  judges_pool.shuffle!
  documents = area.documents.shuffle
  puts "IN CATEGORY #{area.name} -------------------------------------------------------------"
  puts "                         JUDGES (#{judges_pool.count}): #{judges_pool.map(&:name).join(", ")}"
  puts "                         DOCUMENTS (#{documents.count}): #{documents.map(&:index)}"
  judges_pool.each_with_index do |judge, judge_index|
  puts "            ASSIGNING JUDGE #{judge.name} ARTICLES ..................."

    judge_documents = documents.select do |d|
      documents.index(d) % judges_pool.length == judge_index
    end
    puts "            ARTICLES #{judge_documents.map(&:index)}"
    judge.documents << judge_documents
    judge.save
  end

end