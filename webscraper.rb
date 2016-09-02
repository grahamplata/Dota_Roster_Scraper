#!/usr/bin/env ruby

require 'mechanize'
require 'json'

# Provides helper methods for interacting with Mechanize DOM elements
module MechanizeHelper
  # Extracts text from the first member of a given CSS selector
  def extract_text(element, selector)
    element.css(selector).first.text.strip
  end
end

# Scrapes a table-like element from a given URL, and allows the user to process
# each row in the table with a provided block.
class TableScraper
  include MechanizeHelper

  DEFAULT_USER_AGENT = 'Mac Safari'

  def initialize(config)
    @config = OpenStruct.new(config)
    @scraper = Mechanize.new do |agent|
      agent.user_agent_alias = @config.user_agent || DEFAULT_USER_AGENT
    end
  end

  # Scrapes a table-like element, and processes each row with a block
  def scrape(&block)
    page = @scraper.get(@config.target_url)
    rows = page.css(@config.rows_selector)

    content = rows.map do |row|
      yield(row)
    end

    JSON.pretty_generate(content)
  end
end

# Scrapes a DotA roster from dota2.com
class DotaRosterScraper < TableScraper
  def scrape
    super do |row|
      if block_given?
        yield(row, @config)
      else
        {
          player_name: extract_text(row, @config.player_name_selector),
          team_name: extract_text(row, @config.team_name_selector),
          team_id: extract_text(row, @config.team_id_selector).match(@config.team_id_pattern).captures.first,
          action: extract_text(row, @config.action_selector)
        }
      end
    end
  end
end

scraper = DotaRosterScraper.new(
  # Scraper configuration
  target_url: 'http://www.dota2.com/majorsregistration/list',
  user_agent: 'Mac Safari',

  # Selectors
  rows_selector: 'div.ConfirmationRow',
  player_name_selector: 'div.OptimizeTextRadiance:nth-child(4) > span',
  team_name_selector: 'div.OptimizeTextRadiance:nth-child(5) > span',
  team_id_selector: 'div.OptimizeTextRadiance:nth-child(5)',
  action_selector: 'div.OptimizeTextRadiance:nth-child(6)',

  # Miscellaneous
  team_id_pattern: /\(ID: (\d+)\)/i
)

puts scraper.scrape
