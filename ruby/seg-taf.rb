require 'chronic_duration'
require 'nokogiri'
require 'yaml'
require_relative 'auto-seg'

MAX_PROCESS = 6

def seg_file(src, dest)
  print File.basename(src) + ' '
  robot = AutoSeg.new
  doc = File.open(src) { |f| Nokogiri::XML(f) }
  doc.remove_namespaces!
  body = doc.at_xpath('//body')
  body.search('.//text()').each do |node|
    next if node.parent.name == 'ab' and node.parent['type'] == "dharani"
    next if node.content.gsub(/\s/, '').empty?
    node.content = robot.run(node.text)
  end
  File.write(dest, doc.to_xml)
end

def seg_folder(src, dest)
  FileUtils.rm_rf(dest)
  FileUtils.makedirs(dest)
  Dir.entries(src).sort.each do |f|
    next if f.start_with?('.')
    p1 = File.join(src, f)
    p2 = File.join(dest, f)
    if Dir.exist?(p1)
      seg_folder(p1, p2)
    else
      # 如果目前執行的 process 數量超過最大值，就先等某個 child process 結束
      Process.wait if $process_counter >= MAX_PROCESS
      $process_counter += 1
      fork do
        seg_file(p1, p2)
      end
    end
  end
end

t1 = Time.now
$process_counter = 0
$config = YAML.load_file('config.yml')

dest = File.join($config['seged'], 'one-text-as-a-file', 'seged-taf')
seg_folder($config['cbeta_taf_xml'], dest)
Process.waitall
puts "花費時間：" + ChronicDuration.output(Time.now - t1)