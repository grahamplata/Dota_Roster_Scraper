#!/usr/bin/env ruby

require 'mechanize'
require 'json'

TARGET_URL = 'http://www.dota2.com/majorsregistration/list'
USER_AGENT = 'Mac Safari'
SCRAPER = Mechanize.new { |agent| agent.user_agent_alias = USER_AGENT }

CONFIG = OpenStruct.new(
  # Selectors
  rows_selector: 'div.ConfirmationRow',
  player_name_selector: 'div.OptimizeTextRadiance:nth-child(4) > span',
  team_name_selector: 'div.OptimizeTextRadiance:nth-child(5) > span',
  team_id_selector: 'div.OptimizeTextRadiance:nth-child(5)',
  action_selector: 'div.OptimizeTextRadiance:nth-child(6)',

  # Miscellaneous
  team_id_pattern: /\(ID: (\d+)\)/i
)

# Scrapes a table-like element, and processes each row with a block
def scrape_table(url, rows_selector, &block)
  page = SCRAPER.get(url)
  rows = page.css(rows_selector)

  contents = rows.map do |row|
    yield(row)
  end

  contents
end

# Extracts text from the first member of a given CSS selector
def extract_text(element, selector)
  element.css(selector).first.text.strip
end

# Scrapes the table and processes each row
output = scrape_table(TARGET_URL, CONFIG.rows_selector) do |row|
  {
    player_name: extract_text(row, CONFIG.player_name_selector),
    team_name: extract_text(row, CONFIG.team_name_selector),
    team_id: extract_text(row, CONFIG.team_id_selector).match(CONFIG.team_id_pattern).captures.first,
    action: extract_text(row, CONFIG.action_selector)
  }
end

puts JSON.pretty_generate(output)
