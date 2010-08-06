#!/usr/bin/env ruby
require 'rubygems'
require 'rexml/document'
require 'CSV'
include REXML

#open xml, use to create a csv
xmlfile = File.new("fontanelle_slot1.xml")
xmldoc = Document.new(xmlfile)
puts "start"

writer = CSV.open('fontanelle_slot1.csv','w')
xmldoc.elements.each("markers/marker") do |e| 
  lat = e.attributes["lat"].strip
  lng = e.attributes["lng"].strip
  title = e.attributes["UBICAZIONE"].strip.downcase.gsub(/\b\w/){$&.upcase}
  note = nil
  photo = nil
  #puts "element #{e.name} lat:#{lat} lng:#{lng} title:#{title}"
  row = [lat, lng, title, note, photo]
  puts row
  writer <<row 
end
writer.close
puts "end"