require "dotenv/load"
require "pry"

require "mechanize"
require "time"
require "csv"

module BqSync
  module Fetcher
    class Twitter
      def initialize
        @id = ENV["TWITTER_ID"]
        @password = ENV["TWITTER_PASSWORD"]
      end

      def tweet_activity(from:, to:)
        start_time = from.to_i.to_s + "000"
        end_time = (to.to_i + (60 * 60 * 24 - 1)).to_s + "999"

        agent = Mechanize.new
        agent.user_agent_alias = "Windows Mozilla"
        url = "https://analytics.twitter.com/user/#{@id}/tweets"
        export_url = "#{url}/export.json?start_time=#{start_time}&end_time=#{end_time}&lang=en"
        bundle_url = "#{url}/bundle?start_time=#{start_time}&end_time=#{end_time}&lang=en"

        page = agent.get(url)
        form = page.form_with(action: "https://twitter.com/sessions")
        form.fields[0].value = @id
        form.fields[1].value = @password
        form.submit

        iterate = (to.to_i - from.to_i) / (60 * 60 * 24) + 1
        iterate.times do |_|
          agent.post(export_url, "")
          sleep(1)
        end

        file = agent.get(bundle_url)
        while file.code != "200"
          file = agent.get(bundle_url)
          sleep(1)
        end

        body = CGI.unescape(file.body)
        CSV.parse(body)
      end
    end
  end
end
