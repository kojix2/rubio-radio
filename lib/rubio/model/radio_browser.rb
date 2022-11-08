# frozen_string_literal: true

require 'json'
require 'open-uri'

require_relative 'station'

module Rubio
  module Model
    # https://www.radio-browser.info
    module RadioBrowser
      module_function

      def base_url
        'http://all.api.radio-browser.info/json/'
      end

      def topvote(n = 100, offset: 0)
        content = URI.parse(base_url + "stations/topvote/#{n}?offset=#{offset}")
        result = []
        JSON[content.read].each_with_index do |s, _i|
          result << Station.new(s['stationuuid'], s['name'], s['language'], s['country'], s['url_resolved'])
        end
        result
      end
    end
  end
end
