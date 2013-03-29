require 'uri'
require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'json'

require 'pry'

data = []
url = "http://www.ura.gov.sg/realEstateIIWeb/price/submitSearch.action"

date_range = (Date.new(2007, 6)..Date.today.prev_month).select{|d| d.day == 1}
date_range.each do |date|
  year = date.year
  month = date.strftime('%m')

  response = Net::HTTP.post_form(URI.parse(url), yearSelect: year, monthSelect: month)
  page = Nokogiri::HTML(response.body)

  table = page.css('#SubmitSortForm table')
  fields = table.css('table > thead > tr > td').map(&:text).map(&:strip)
  rows = table.css('tr.rowalternate')

  next if table.empty? || fields.empty? || rows.empty?

  rows.each do |r|
    values = r.css('td').map{|cell| cell.text.strip }
    data << Hash[fields.zip values]
  end
  puts "done with #{year} #{month}"
end

File.open('data.json', 'w') do |f|
  f.puts data.to_json
end

# helpers

def save_and_open_page response
  File.open('test.html', 'w') do |f|
    f.puts response.body
  end
  `open test.html`
end
