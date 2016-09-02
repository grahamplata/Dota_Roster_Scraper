require 'mechanize'
require 'json'

#setup mechanize
mechanize = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


#declare page to be scraped
page = mechanize.get('http://www.dota2.com/majorsregistration/list')

#find page title
puts page.title

#find table
table = page.css('div.ConfirmationRow')
#find row
row = table.css('div.OptimizeTextRadiance')


#content arrays
playerARRAY = []
row.css('span').each_with_index do |x, index|
  #scrape player logic
  if index.even?
    player_name = x.text
    playerARRAY.push(player: player_name)
  end
end
teamARRAY = []
row.css('span').each_with_index do |x, index|
  #scrape team logic
  if index.odd?
    team_name = x.text
    teamARRAY.push(team: team_name)
  end
end

####################################################
myhash = {}
playerARRAY.each_with_index {|k,i|myhash[k] = teamARRAY[i]}


puts JSON.pretty_generate(myhash)
