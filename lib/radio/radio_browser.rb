# frozen_string_literal: true

class Radio
  module RadioBrowser
    module_function

    def base_url
      'http://all.api.radio-browser.info/json/'
    end

    def topvote(n = 100)
      content = URI.parse(base_url + "stations/topvote/#{n}")
      JSON[content.read].map do |s|
        Station.new(s['name'], s['language'], s['url_resolved'])
      end
    end
  end
end
