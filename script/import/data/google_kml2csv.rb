#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'CSV'


url = 'http://maps.google.co.uk/maps/ms?ie=UTF8&hl=en&vps=1&jsv=180e&oe=UTF8&msa=0&msid=112110715492804736105.000468df54bca0e71a570&output=kml'

file = 'puglia_generated_source.html'
doc = Nokogiri::XML(open(url))


writer = CSV.open('london1.csv','w')
doc.xpath('//xmlns:Placemark').each do |item|
  puts "item"
  title = item.xpath('xmlns:name').first.content
  #note = item.xpath('xmlns:description').first.content
  note = '' #descriptions are too heterogeneous to handle. embedded markup, no standard. I could strip out all tags but it would look ugly as the markup hasn't been used in a consistent way.
  
  coords = item.xpath('xmlns:Point/xmlns:coordinates').first.content.split(',')
  lat = coords[1]
  lng = coords[0]
  photo = nil
  
  row = [lat, lng, title, note, photo]
  puts row
  writer <<row
end
writer.close
puts "CSV generated. To load run:"
puts "./script/runner script/import/batch_dripplets.rb script/import/data/london1.csv"
puts "end"
