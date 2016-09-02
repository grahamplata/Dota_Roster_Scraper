#!/usr/bin/env ruby

require 'mechanize'
require 'json'

TARGET_URL = 'http://www.dota2.com/majorsregistration/list'
USER_AGENT = 'Mac Safari'
SCRAPER = Mechanize.new { |agent| agent.user_agent_alias = USER_AGENT }

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
output = scrape_table(TARGET_URL, 'div.ConfirmationRow') do |row|
  {
    player_name: extract_text(row, 'div.OptimizeTextRadiance:nth-child(4) > span'),
    team_name: extract_text(row, 'div.OptimizeTextRadiance:nth-child(5) > span'),
    action: extract_text(row, 'div.OptimizeTextRadiance:nth-child(6)')
  }
end

puts JSON.pretty_generate(output)
