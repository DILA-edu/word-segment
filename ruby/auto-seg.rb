require 'open3'
require 'tempfile'
require_relative 'crf'

class AutoSeg
  def initialize
    @crf = CRF.new('dicts/words.json', 'dicts/dila.json')
    @model = 'crf-model'
  end

  def run(text)
    s = text.gsub(/ /, '/')
    
    a = s.split(/([\n\/\.\(\)\[\]\-　．。，、？！：；「」『』《》＜＞〈〉〔〕［］【】〖〗（）…—◎])/)
    s_after_tag = ''
    a.each do |s|
      s_after_tag += @crf.tag_string3(s, 'seg')
    end
    
    s = Tempfile.create("word-seg") do |f|
      f.write(s_after_tag)
      f.close
      cmd = "crf_test -m #{@model} #{f.path}"
      stdout, stderr, status = Open3.capture3(cmd)
      if status.success?
        stdout
      else
        raise "執行 crf_text 發生錯誤: #{stderr}"
      end
    end
    
    tag2slash(s)
  end

  private

  def tag2slash(lines)
    r = ''
    lines.each_line do |s|
      s.chomp!
      next if s.empty?
      a = s.split
  
      if a.first == "\u2028"
        r += "\n"
      else
        r += case a.last
        when 'S' then '/' + a.first + '/'
        when 'B' then '/' + a.first
        when 'E' then a.first + '/'
        else a.first
        end
      end
    end
    r.gsub(/\/{2,}/, '/')
  end

end
