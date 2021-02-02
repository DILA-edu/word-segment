require 'fileutils'
require 'nokogiri'
require 'yaml'

def convert_file(src, dest)
  print File.basename(src) + ' '
  doc = File.open(src) { |f| Nokogiri::XML(f) }
  doc.remove_namespaces!
  body = doc.at_xpath('//body')
  File.write(dest, body.text)
end

def convert_folder(src, dest)
  puts "\n#{src}"
  FileUtils.rm_rf(dest)
  FileUtils.makedirs(dest)
  Dir.entries(src).sort.each do |f|
    next if f.start_with?('.')
    p1 = File.join(src, f)
    if Dir.exist?(p1)
      p2 = File.join(dest, f)
      convert_folder(p1, p2)
    else
      b = File.basename(f, '.xml')
      p2 = File.join(dest, "#{b}.txt")
      convert_file(p1, p2)
    end
  end
end

$config = YAML.load_file('config.yml')
convert_folder($config['seged_taf'], $config['seged_txt'])
