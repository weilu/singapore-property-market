require 'uri'
require 'open-uri'
require 'net/http'
require 'nokogiri'
require 'csv'

require 'pry'

data = []
url = "http://www.ura.gov.sg/realEstateIIWeb/price/submitSearch.action"

date_range = (Date.new(2007, 6)..Date.today.prev_month).select{|d| d.day == 1}
CSV.open("data.csv", "ab") do |csv|
  date_range.each do |date|
    year = date.year
    month = date.strftime('%m')

    response = Net::HTTP.post_form(URI.parse(url), yearSelect: year, monthSelect: month)
    page = Nokogiri::HTML(response.body)

    table = page.css('#SubmitSortForm table')
    unless defined? fields
      fields = table.css('table > thead > tr > td').map(&:text).map(&:strip)
      csv << ['year', 'month'] + fields
    end
    rows = table.css('tr.rowalternate')

    next if table.empty? || fields.empty? || rows.empty?

    rows.each do |r|
      values = r.css('td').map{|cell| cell.text.strip }
      csv << [year, month] + values
    end

    puts "done with #{year} #{month}"
  end
end

# helpers

def save_and_open_page response
  File.open('test.html', 'w') do |f|
    f.puts response.body
  end
  `open test.html`
end
