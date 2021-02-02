# 讀 CBETA P5 XML 轉出較簡單的 XML 供文獻分析使用
# 轉換規則見 simple-xml-rules.md
# 執行例:
#  轉 CBETA 全部: ruby taf.rb
#  轉大正藏: ruby taf.rb T
#  轉大正藏第三冊: ruby taf.rb T03
#  轉大正藏第三冊至第八冊: ruby taf.rb T03..T08

require 'fileutils'
require 'yaml'
require_relative 'p5a_to_sx'

def convert_all
  Dir.entries($in).sort.each do |c|
    next if c.start_with?('.')
    next if c.size > 2
    convert_canon(c)
  end
end

def convert_canon(c)
  src = File.join($in, c)
  Dir.entries($in).sort.each do |f|
    next if f.start_with?('.')
    convert_vol(c, f)
  end
end

def convert_sutra(folder_in, folder_out, sutra)
  args = {
    vol: $vol,
    work: sutra,
    src: File.join(folder_in, sutra+'.xml'),
    dest: File.join(folder_out, sutra+'.xml')
  }
  $converter.run(args)
end

def convert_vol(canon, vol)
  puts "\nconvert vol: #{vol}"
  $vol = vol
  dest = File.join($out, canon, vol)
  FileUtils.rm_rf(dest)
  FileUtils.makedirs(dest)
    
  source = File.join($in, canon, vol)
  Dir.entries(source).sort.each do |f|
    next unless f.end_with? '.xml'
    $sutra_no = File.basename(f, '.xml')
    print $sutra_no + ' '
    convert_sutra(source, dest, $sutra_no)
  end
end

# main
$config = YAML.load_file('config.yml')
$in = $config['cbeta_xml_p5a']
$out = $config['cbeta_taf_xml']
FileUtils.makedirs($out)

$converter = P5aToSimpleXML.new($config['gaiji'])

if ARGV.empty?
  convert_all
else
  arg = ARGV[0]
  if arg.size < 3
    convert_canon(arg)
  elsif arg.include? '..'
    v1, v2 = ARGV[0].split('..')

    canon = CBETA.get_canon_from_vol(v1)
    folder = File.join($in, canon)
    Dir.entries(folder).sort.each do |vol|
      next if vol.start_with? '.'
      next if (vol < v1) or (vol > v2)
      convert_vol(canon, vol)
    end
  else
    vol = arg.upcase
    canon = CBETA.get_canon_from_vol(vol)
    convert_vol(canon, vol)
  end
end