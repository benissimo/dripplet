#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'CSV'

#http://nokogiri.org/tutorials/parsing_an_html_xml_document.html

#url = 'http://maps.google.it/maps/ms?ie=UTF8&hl=it&msa=0&msid=113134578535608684898.00047106d5aa9d1048d77&ll=41.115314,16.850967&spn=0.145364,0.312767&t=h&z=12'

url = 'http://maps.google.it/maps/ms?ie=UTF8&hl=it&t=h&msa=0&output=georss&msid=113134578535608684898.00047106d5aa9d1048d77'

file = 'puglia_generated_source.html'
doc = Nokogiri::XML(open(url))
#doc = Nokogiri::HTML(File.open(file))

# need to grab the generated source (produced by JS) so I have something cleaner to parse.

writer = CSV.open('puglia1.csv','w')
doc.xpath('//item').each do |item|
  title = item.xpath('title').first.content
  desc_html = item.xpath('description').first.content
  frag = Nokogiri::HTML(desc_html)
  if frag.css('div').first
    note = frag.css('div').first.content
  else
    note = ""
  end
  lat,lng = item.xpath('georss:point').first.content.split
  photo = nil
  
  row = [lat, lng, title, note, photo]
  puts row
  writer <<row
end
writer.close
puts "CSV generated. To load run:"
puts "./script/runner script/import/batch_dripplets.rb script/import/data/puglia1.csv"
puts "end"
