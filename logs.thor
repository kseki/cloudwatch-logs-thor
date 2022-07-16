# frozen_string_literal: true

require 'aws-sdk-cloudwatchlogs'
require 'thor'

# Doc: https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CloudWatchLogs.html
class Logs < Thor
  desc 'log_groups', 'Lists the log groups.'

  # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CloudWatchLogs/Client.html#describe_log_groups-instance_method
  method_option :attribute,
                aliases: '-a',
                desc: 'Attributes to output.'

  def log_groups
    attribute = options[:attribute] || 'log_group_name'

    client.describe_log_groups.each_page do |res|
      res.log_groups.each { |g| puts g.send attribute }
    end
  end

  desc 'filter', 'Lists log events from the specified log group.'

  # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/CloudWatchLogs/Client.html#filter_log_events-instance_method
  method_option :log_group_name,
                aliases: '-l',
                desc: 'Log group name to search.'

  method_option :filter_pattern,
                aliases: '-f',
                desc: 'Search filters'

  method_option :start,
                aliases: '-s',
                desc: 'start time'

  method_option :end,
                aliases: '-e',
                desc: 'end time'

  def filter
    start_time = Time.parse(options[:start])
    end_time = Time.parse(options[:end])

    params = {
      log_group_name: options[:log_group_name],
      filter_pattern: options[:filter_pattern],
      start_time: start_time.to_f * 1000.0,
      end_time: end_time.to_f * 1000.0,
      limit: 5,
      interleaved: true
    }
    client.filter_log_events(params).each_page do |res|
      res.events.each { |event| puts event.message }
    end
  end

  private

  def client
    @client ||= Aws::CloudWatchLogs::Client.new
  end
end
