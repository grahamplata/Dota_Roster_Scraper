require 'mechanize'
require 'json'

#setup mechanize
mechanize = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

#content array
contents = []
#declare page to be scraped
page = mechanize.get('http://www.dota2.com/majorsregistration/list')

#find page title
puts page.title

#find table
table = page.css('div.ConfirmationRow')
#find row
row = table.css('div.OptimizeTextRadiance')

row.css('span').each_with_index do |x, index|
  #team or player logic
    if (index % 2 == 0)
      player_name = x['player']
      puts "\nPlayer: #{x.text}"
    else
      player_team = x['team']
      puts "Team: #{x.text}"
    end

    contents.push(
      player: player_name,
      team: player_team
      )

end
#generate JSON data
  puts JSON.pretty_generate(contents)
