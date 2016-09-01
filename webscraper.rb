require 'mechanize'

mechanize = Mechanize.new

page = mechanize.get('http://www.dota2.com/majorsregistration/list')

puts page.title
puts
