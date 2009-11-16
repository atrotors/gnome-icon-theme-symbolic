#!/usr/bin/env ruby

require "rexml/document"
require "fileutils"
include REXML

INKSCAPE = '/usr/bin/inkscape'
SRC = "gnome-osd-icons.svg"
PREFIX = "gnome-osd-icons/24x24"

def chopSVG(icon)
	FileUtils.mkdir_p(icon[:dir]) unless File.exists?(icon[:dir])
	unless (File.exists?(icon[:file]) && !icon[:forcerender])
		FileUtils.cp(SRC,icon[:file]) 
		puts " >> #{icon[:name]}"
		cmd = "#{INKSCAPE} -f #{icon[:file]} --select #{icon[:id]} --verb=FitCanvasToSelection  --verb=EditInvertInAllLayers "
		cmd += "--verb=EditDelete --verb=EditSelectAll --verb=SelectionUnGroup --verb=StrokeToPath --verb=FileVacuum "
		cmd += "--verb=FileSave --verb=FileClose > /dev/null 2>&1"
		system(cmd)
		cmd = "#{INKSCAPE} -f #{icon[:file]} -z --vacuum-defs -l #{icon[:file]} > /dev/null 2>&1"
		system(cmd)
		system cmd unless (!icon[:dir].match(/app/))
	else
		puts " -- #{icon[:name]} already exists"
	end
end #end of function


#main
# Open SVG file.
svg = Document.new(File.new(SRC, 'r'))

if (ARGV[0].nil?) #render all SVGs
  puts "Rendering from icons in #{SRC}"
	# Go through every layer.
	svg.root.each_element("/svg/g[@inkscape:groupmode='layer']") do |context| 
		context_name = context.attributes.get_attribute("inkscape:label").value  
#		puts "Going through layer '" + type_name + "'"
		context.each_element("g") do |icon|
			dir = "#{PREFIX}/#{context_name}"
			icon_name = icon.attributes.get_attribute("inkscape:label").value
			chopSVG({	:name => icon_name,
			 					:id => icon.attributes.get_attribute("id"),
			 					:dir => dir,
			 					:file => "#{dir}/#{icon_name}.svg"})
		end
	end
  puts "\nrendered all SVGs"
else #only render the icons passed
  icons = ARGV
  ARGV.each do |icon_name|
  	icon = svg.root.elements["//g[@inkscape:label='#{icon_name}']"]
  	dir = "#{PREFIX}/#{icon.parent.attributes['inkscape:label']}"
		chopSVG({	:name => icon_name,
		 					:id => icon.attributes["id"],
		 					:dir => dir,
		 					:file => "#{dir}/#{icon_name}.svg",
		 					:forcerender => true})
	end
  puts "\nrendered #{ARGV.length} icons"
end
