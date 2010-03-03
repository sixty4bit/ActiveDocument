require 'net/http'
require 'uri'
require 'digest/md5'

module Net
  module HTTPHeader
    @@nonce_count = -1
    CNONCE = Digest::MD5.new.update("%x" % (Time.now.to_i + rand(65535))).hexdigest

    def digest_auth(user, password, response)
      # based on http://segment7.net/projects/ruby/snippets/digest_auth.rb
      @@nonce_count += 1

      response['www-authenticate'] =~ /^(\w+) (.*)/

      params = {}
      $2.gsub(/(\w+)="(.*?)"/) { params[$1] = $2 }

      a_1 = "#{user}:#{params['realm']}:#{password}"
      a_2 = "#{@method}:#{@path}"
      request_digest = ''
      request_digest << Digest::MD5.new.update(a_1).hexdigest
      request_digest << ':' << params['nonce']
      request_digest << ':' << ('%08x' % @@nonce_count)
      request_digest << ':' << CNONCE
      request_digest << ':' << params['qop']
      request_digest << ':' << Digest::MD5.new.update(a_2).hexdigest

      header = []
      header << "Digest username=\"#{user}\""
      header << "realm=\"#{params['realm']}\""

      header << "qop=#{params['qop']}"

      header << "algorithm=MD5"
      header << "uri=\"#{@path}\""
      header << "nonce=\"#{params['nonce']}\""
      header << "nc=#{'%08x' % @@nonce_count}"
      header << "cnonce=\"#{CNONCE}\""
      header << "response=\"#{Digest::MD5.new.update(request_digest).hexdigest}\""

      @header['Authorization'] = header
    end
  end
end

module ActiveDocument

  class MarkLogicHTTP

    def initialize
      @url = URI.parse('http://localhost:8000/dynamic_dispatch.xqy')
      @user_name = 'admin'
      @password = 'admin'
    end

    def send_xquery(xquery)
      if xquery.nil? or xquery.empty? then
        return nil
      end
      req = authenticate()
      req.set_form_data({'request'=>"#{xquery}"})
      res = Net::HTTP.new(@url.host, @url.port).start {|http| http.request(req) }
      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
#          puts res.body
          res.body
        else
          res.error!
      end
    end

    private
    def authenticate
      req = Net::HTTP::Post.new(@url.path)
      Net::HTTP.start(@url.host, @url.port) do |http|
        res = http.head(@url.request_uri)
        req.digest_auth(@user_name, @password, res)
      end
      return req
    end
  end
end