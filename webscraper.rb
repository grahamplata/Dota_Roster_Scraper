#!/usr/bin/env ruby

require 'mechanize'
require 'json'

TARGET_URL = 'http://www.dota2.com/majorsregistration/list'
USER_AGENT = 'Mac Safari'

mechanize = Mechanize.new { |agent| agent.user_agent_alias = USER_AGENT }

page = mechanize.get(TARGET_URL)

def extract_text(element, selector)
  element.css(selector).first.text.strip
end

rows = page.css('div.ConfirmationRow')
contents = rows.map do |row|
  {
    player_name: extract_text(row, 'div.OptimizeTextRadiance:nth-child(4) > span'),
    team_name: extract_text(row, 'div.OptimizeTextRadiance:nth-child(5) > span'),
    action: extract_text(row, 'div.OptimizeTextRadiance:nth-child(6)')
  }
end

puts JSON.pretty_generate(contents)
