require 'fileutils'
require 'nokogiri'
require 'cbeta'

# 內容不輸出的元素
PASS = %w[back docNumber graphic milestone mulu note orig rdg sg sic teiHeader trailer]

# 忽略下一層的 white space
IGNORE=['TEI', 'text']

class P5aToSimpleXML
  def initialize(gaiji)
    fn = File.join(gaiji, 'cbeta_gaiji.json')
    @gaijis = JSON.parse(File.read(fn))

    fn = File.join(gaiji, 'cbeta_sanskrit.json')
    @gaijis_skt = JSON.parse(File.read(fn))

    @xml_template = File.read('template.xml')
  end

  def run(args)
    @ab_type = nil
    @div_level = 0
    @gaiji_norm = [true]
    @list_level = 0
    @next_line_buf = ''

    doc = File.open(args[:src]) { |f| Nokogiri::XML(f) }
    doc.remove_namespaces!
  
    e = doc.at('//title')
    title = traverse(e)
    @title = title.split.last
    puts "title 是空的" if @title.empty?
    
    body = traverse(doc.root)

    xml = @xml_template % {
      title: @title,
      vol: args[:vol],
      work: args[:work],
      date: Date.today,
      body: body
    }
    
    File.write(args[:dest], xml)
  end
  
  private
  
  def ab(type, e)
    r = open_ab(type)
    r += traverse(e)
    r + close_ab
  end

  def chk_behaviour(e)
    norm = true
    if e['behaviour'] == "no-norm"
      norm = false
    end
    @gaiji_norm.push norm
    r = traverse(e)
    @gaiji_norm.pop
    r
  end

  def e_body(e)
    r = ''
    divs = e.search('div')
    
    # 如果 body 下有多個 div, 在最外層再包一個大 div
    if divs.size > 1
      @div_level = 1
      r = "<div level='1'>" + traverse(e)
      r += close_ab + '</div>'
      @div_level = 0
    else
      # 如果 body 只有一個 div, 而這個 div 的 type 是 other, 
      # 這個 div 會被忽略, 所以還是要在最外層再包一個大 div
      div = e.at('div')
      if div['type'] == 'other'
        @div_level = 1
        r += "<div level='1'>" + traverse(e)
        r += close_ab + '</div>'
        @div_level = 0
      else
        r += traverse(e)
        r += close_ab
      end
    end
    r
  end
  
  def e_byline(e)
    "\n<byline>" + traverse(e) + '</byline>'
  end
  
  def e_div(e)
    r = ''
    if e['type'] == 'other'
      r += traverse(e)
    else
      @div_level += 1
      r = close_ab
      r += "\n<div type='#{e['type']}' level='#{@div_level}'>"
      r += traverse(e)
      r += close_ab
      @div_level -= 1
      r += '</div>'
    end
    r
  end

  def e_foreign(e)
    return '' if e.key?('place') and e['place'].include?('foot')
    traverse(e)
  end

  def e_g(e)
    gid = e['ref'][1..-1]
    
    if gid.start_with? 'CB'
      g = @gaijis[gid]
    else
      g = @gaijis_skt[gid]
      return g['romanized'] if g.key?('romanized')
      return CBETA.pua(gid)
    end
    
    return g['uni_char'] if g.key?('uni_char')

    if @gaiji_norm.last # 如果 沒有特別說 不能用 通用字
      %w[norm_uni_char norm_big5_char].each do |k|
        return g[k] if g.key?(k)
      end
    end

    CBETA.pua(gid)
  end

  def e_head(e)
    return '' if e['type'] == 'no'
    
    '<head>' + traverse(e) + '</head>'
  end
  
  def e_juan(e)
    r = close_ab
    r += "\n<ab type='juan' subtype='#{e['fun']}'>"
    r += traverse(e) + '</ab>'
  end

  def e_lb(e)
    unless @next_line_buf.empty?
      r = "\n" + @next_line_buf + "\n"
      @next_line_buf = ''
      return r
    end
    ''
  end
  
  def e_lg(e)
    r = open_ab('verse')
    r += traverse(e)
    r.sub!(/　+$/, '')
    r += close_ab
  end

  def e_list(e)
    @list_level += 1
    if @list_level == 1
      r = ab('list', e)
    else
      r = traverse(e)
    end
    @list_level -= 1
    r
  end
  
  def e_p(e)
    r = ''
    if e['type'] == "dharani"
      r += open_ab("dharani")
    else
      r += open_ab("prose")
    end
    r + traverse(e)
  end
  
  def e_t(e)
    return '' if e.key?('place') and e['place'].include? 'foot'
    
    r = traverse(e)
    tt = e.at_xpath('ancestor::tt')
    unless tt.nil?
      return r if %w(app single-line).include? tt['type']
      return r if tt['rend'] == 'normal'
      return r if tt['place'] == 'inline'
    end

    # 處理雙行對照
    # <tt type="tr"> 也是 雙行對照
    i = e.xpath('../t').index(e)
    case i
    when 0
      return r + '　'
    when 1
      @next_line_buf += r + '　'
      return ''
    else
      return r
    end
  end

  def e_unclear(e)
    r = traverse(e)
    r = '⍰' if r.empty?
    r
  end

  def handle_node(e)
    return '' if e.comment?
    return handle_text(e) if e.text?
    return '' if PASS.include? e.name
    
    r = case e.name
    when 'body'    then e_body(e)
    when 'byline'  then e_byline(e)
    when 'caesura' then '　'
    when 'cell'    then ab('cell', e)
    when 'div'     then e_div(e)
    when 'foreign' then e_foreign(e)
    when 'g'       then e_g(e)
    when 'head'    then e_head(e)
    when 'item'    then "\n" + ('　' * (@list_level-1)) + traverse(e)
    when 'juan'    then e_juan(e)
    when 'l'       then traverse(e) + "\n"
    when 'lb'      then e_lb(e)
    when 'lg'      then e_lg(e)
    when 'list'    then e_list(e)
    when 'p'       then e_p(e)
    when 'row'     then ab('row', e)
    when 't'       then e_t(e)
    when 'term'    then chk_behaviour(e)
    when 'table'   then ab('table', e)
    when 'text'    then chk_behaviour(e)
    when 'unclear' then e_unclear(e)
    else traverse(e)
    end
    r
  end

  def handle_text(e)
    return '' if IGNORE.include? e.parent.name
    
    s = e.content().chomp
    return '' if s.empty?
    
    r = s.gsub("\n", '')
    r.gsub!('&', '&amp;')
    r.gsub!('<', '&lt;')
    r
  end

  def traverse(e)
    r = ''
    e.children.each { |c| 
      r += handle_node(c)
    }
    r
  end

  def open_ab(type)
    r = ''
    if @ab_type.nil?
      r = "\n<ab type='#{type}'>"
    elsif @ab_type != type
      r = "</ab>\n"
      r += "<ab type='#{type}'>"
    end
    @ab_type = type
    r
  end

  def close_ab
    r = ''
    unless @ab_type.nil?
      r = '</ab>'
      @ab_type = nil
    end
    r
  end
    

end