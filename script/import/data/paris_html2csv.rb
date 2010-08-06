#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'CSV'


file = 'paris.html'
#doc = Nokogiri::XML(open(url))
doc = Nokogiri::HTML(File.open(file))

# need to grab the generated source (produced by JS) so I have something cleaner to parse.

writer = CSV.open('paris1.csv','w')
puts "begin"
doc.css('#directory-directory-4 tr').each do |item|
  puts "row"
  unless item.css('th').first
    title = item.css('.directory-entry-23').first.content# + " - " + item.css('.directory-entry-24').first.content
    note = item.css('.directory-entry-25').first.content
    lat = item.css('.x').first.content
    lng = item.css('.y').first.content
    photo = nil
  
    row = [lat, lng, title, note, photo]
    puts row
    writer <<row
  end
end
writer.close
puts "CSV generated. To load run:"
puts "./script/runner script/import/batch_dripplets.rb script/import/data/paris1.csv"
puts "end"
