require 'fileutils'
require 'nokogiri'
require 'yaml'

def convert_file(src, dest1, dest2)
  FileUtils.rm_rf(dest2)
  FileUtils.makedirs(dest2)

  basename = File.basename(src, '.*')
  print basename + ' '

  doc = File.open(src) { |f| Nokogiri::XML(f) }
  doc.remove_namespaces!
  $juans = Hash.new { |hash, key| hash[key] = "" }
  $juan = 1

  body = doc.at_xpath('//body')
  traverse(body)

  fo = File.open(dest1, 'w')
  $juans.each do |juan, text|
    fo.write text
    fn = "#{basename}_%03d.txt" % juan
    fn = File.join(dest2, fn)
    File.write(fn, text)
  end
  fo.close
end

def convert_folder(src, dest1, dest2)
  puts "\nread: #{src}"

  FileUtils.rm_rf(dest1)
  FileUtils.rm_rf(dest2)
  FileUtils.makedirs(dest1)
  FileUtils.makedirs(dest2)

  Dir.entries(src).sort.each do |f|
    next if f.start_with?('.')
    p1 = File.join(src, f)
    if Dir.exist?(p1)
      d1 = File.join(dest1, f)
      d2 = File.join(dest2, f)
      convert_folder(p1, d1, d2)
    else
      b = File.basename(f, '.xml')
      f1 = File.join(dest1, "#{b}.txt")
      d2 = File.join(dest2, b)
      convert_file(p1, f1, d2)
    end
  end
end

def traverse(e)
  e.children.each do |c|
    next if c.comment?
    if c.text?
      $juans[$juan] << c.text
    elsif c.name == 'milestone' and c['unit'] == 'juan'
      $juan = c['n'].to_i
      next
    else
      traverse(c)
    end
  end
end

$config = YAML.load_file('config.yml')
src = File.join($config['seged'], 'seged-taf')
dest = File.join($config['seged'], 'seged-txt')
dest1 = File.join(dest, 'one-text-as-a-file')
dest2 = File.join(dest, 'one-fascile-as-a-file')
convert_folder(src, dest1, dest2)
