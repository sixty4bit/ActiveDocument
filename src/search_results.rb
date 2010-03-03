require 'rubygems'
require 'nokogiri'

module ActiveDocument
  class SearchResults
    include Enumerable
  

    def initialize(results)
      @results_document = Nokogiri::XML(results)
    end

    def total
      Integer(@results_document.xpath("/search:response/@total").to_s)
    end

    def start
      Integer(@results_document.xpath("/search:response/@start").to_s)
    end

    def page_length
      Integer(@results_document.xpath("/search:response/@page-length").to_s)
    end

    def search_text
      @results_document.xpath("/search:response/search:qtext/text()").to_s
    end

    def query_resolution_time
      @results_document.xpath("/search:response/search:metrics/search:query-resolution-time/text()").to_s
    end

    def snippet_resolution_time
      @results_document.xpath("/search:response/search:metrics/search:snippet-resolution-time/text()").to_s
    end

    def facet_resolution_time
      @results_document.xpath("/search:response/search:metrics/search:facet-resolution-time/text()").to_s
    end

    def total_time
      @results_document.xpath("/search:response/search:metrics/search:total-time/text()").to_s
    end

    def each(&block)
      @results_document.xpath("/search:response/search:result").each {|node| yield SearchResult.new(node)}
    end

  end

end