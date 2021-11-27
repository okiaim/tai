=begin
CgiDecode.rb

Copyright (c) [2018] [code-notes.com]

This software is released under the MIT License.
http://opensource.org/licenses/mit-license.php
=end

$_GET = {}
$_POST = {}
$_COOKIE = {}
$_FILES = []

require 'tempfile'

class CgiDecode

  def initialize

    if ENV['REQUEST_METHOD']=='POST'

      if ENV['CONTENT_TYPE'].match(/multipart\/form-data; boundary=(.+)/)

        $_POST = multipart($1)

      else

        $_POST = decode(STDIN.read)
      end
    end

    $_GET = decode(ENV['QUERY_STRING'])
    $_COOKIE = decode(ENV['HTTP_COOKIE'],'; ')

    ObjectSpace.define_finalizer(self, CgiDecode.destruct)
  end

  private
  def decode(buf,de='&')

    h = {}
    r = /%([a-fA-F0-9][a-fA-F0-9])/

    buf.split(de).each do |s|

      (key,val) = s.split('=')

      val = '' if val.nil?

      key.tr!('+',' ')
      key.gsub!(r){[$1].pack('H2')}

      val.tr!('+',' ')
      val.gsub!(r){[$1].pack('H2')}

      setHash(key,val,h)
    end

    return h
  end

  private
  def setHash(key,val,h)

    if h.key?(key)

      if h[key].class==Array

        h[key] << val

      else

        h[key] = [h[key],val]
      end
    else

      h[key] = val
    end

  end

  private
  def multipart(bound)

    key,val,file,type = '','','',''
    h = {}
    f = []
    rec = 0

    r1 = /#{bound}/
    r2 = /Content-Disposition: form-data; name="([^"]+)"; filename="([^"]+)"/
    r3 = /Content-Disposition: form-data; name="([^"]+)"/
    r4 = /Content-Type: (.+)/
    r5 = /\A\r\n\z/

    STDIN.each_line do |li|

      li_utf8 = li.encode('utf-8',:invalid=>:replace)

      if li_utf8 =~ r1

        if key!=''

          val.chomp!

          if file!=''

            GC.disable
            t = Tempfile.open(mode='wb')
            t.write(val)
            t.close(real=false)

            f << {'name'=>key,'up_name'=>file,'type'=>type,'tmp_name'=>t.path}

            file = ''
            type = ''

          else

            setHash(key,val,h)
          end
          key = ''
          val = ''
        end
        rec = 0

      elsif rec==1

        val << li

      elsif li_utf8 =~ r2

        key = $1
        file = $2

      elsif li_utf8 =~ r3

        key = $1

      elsif li_utf8 =~ r4

        type = $1.chomp

      elsif rec==0 && li_utf8 =~ r5

        rec = 1
      end
    end
    $_FILES = f

    return h
  end

  public
  def move(f,name)

    if !File.exists?(f['tmp_name']) || name==''
      return 0
    end

    begin
      File.open(f['tmp_name'],'rb') do |tf|
        File.open(name,'wb') do |nf|
          nf.write(tf.read)
        end
      end
      File.unlink(f['tmp_name'])
      return name

    rescue

      return 0
    end
  end

  def CgiDecode.destruct

    proc {
      GC.start
    }
  end

end
