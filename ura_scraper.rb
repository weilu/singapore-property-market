require 'uri'
require 'net/http'
require 'nokogiri'

url = "http://www.ura.gov.sg/realEstateIIWeb/price/search.action"
params = {
  yearSelect: 2013,
  monthSelect: 01
}
response = Net::HTTP.post_form(URI.parse(url), params)
#puts response.body
page = Nokogiri::HTML(response.body)
