require 'nokogiri'
require 'yaml'
require_relative 'auto-seg'

def seg_file(src, dest)
  print File.basename(src) + ' '
  doc = File.open(src) { |f| Nokogiri::XML(f) }
  doc.remove_namespaces!
  body = doc.at_xpath('//body')
  body.search('.//text()').each do |node|
    next if node.parent.name == 'ab' and node.parent['type'] == "dharani"
    node.content = $robot.run(node.text)
  end
  File.write(dest, doc.to_xml)
end

def seg_folder(src, dest)
  puts "\n#{src}"
  FileUtils.makedirs(dest)
  Dir.entries(src).sort.each do |f|
    next if f.start_with?('.')
    p1 = File.join(src, f)
    p2 = File.join(dest, f)
    if Dir.exist?(p1)
      seg_folder(p1, p2)
    else
      seg_file(p1, p2)
    end
  end
end

$config = YAML.load_file('config.yml')
$robot = AutoSeg.new
seg_folder($config['cbeta_taf_xml'], $config['seged_taf'])
#s = '當觀色無常。如是觀者，則為正觀。正觀者，則生厭離；厭離者，喜貪盡；喜貪盡者，說心解脫。'
