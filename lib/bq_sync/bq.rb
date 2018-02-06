require "pry"
require "google/cloud/bigquery"

module BqSync
  class BQ
    def initialize
      @bigquery = Google::Cloud::Bigquery.new(project: ENV["BIGQUERY_PROJECT_ID"])
    end

    def run(sql)
      puts "big query Running..."
      puts sql
      @bigquery.query sql
    end
  end
end
