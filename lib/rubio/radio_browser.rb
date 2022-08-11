# frozen_string_literal: true

require 'json'
require 'open-uri'

module Rubio
  # https://www.radio-browser.info
  module RadioBrowser
    module_function

    def base_url
      'http://all.api.radio-browser.info/json/'
    end

    def topvote(n = 100)
      content = URI.parse(base_url + "stations/topvote/#{n}")
      result = []
      JSON[content.read].each_with_index do |s, i|
        result << Station.new(s['stationuuid'], s['name'], s['language'], s['url_resolved'])
      end
      result
    end
  end
end
