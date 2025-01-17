require './lib/sortable'

class TeamStats
  include Sortable

  attr_reader :teams, :games, :game_teams

  def initialize(games, game_teams, teams)
    @games = games
		@game_teams = game_teams
    @teams = teams
  end

  def team_info(team_id)
    team_hash = {
      'team_id' => nil,
      'franchise_id' => nil,
      'team_name' => nil,
      'abbreviation' => nil,
      'stadium' => nil,
      'link' => nil
    }

    find_team_by_id[team_id.to_i].each do |team|
    hash_index = 0
      team_hash.each do |info, value|
        team_hash[info] = team.info.values[hash_index].to_s
        hash_index += 1
      end
    end
    team_hash.delete('stadium')
    team_hash
  end

  def best_season(team_id)
    season_win_percentage_by_team(team_id).key(season_win_percentage_by_team(team_id).values.max).to_s
  end

  def worst_season(team_id)
    season_win_percentage_by_team(team_id).key(season_win_percentage_by_team(team_id).values.min).to_s
  end

  def average_win_percentage(team_id)
    games_count = games_by_team_id[team_id.to_i].count.to_f
    wins = games_by_team_id[team_id.to_i].count {|game| game.info[:result] == 'WIN'}
    win_percentage = wins / games_count
    win_percentage.round(2)
  end

  def most_goals_scored(team_id)
		all_game_scores_by_team[team_id.to_i].max
	end
	
	def fewest_goals_scored(team_id)
		all_game_scores_by_team[team_id.to_i].min
	end

	def rival(team_id)
		win_or_loss(team_id.to_i, 'WIN')
	end

	def favorite_opponent(team_id)
		win_or_loss(team_id.to_i, 'LOSS')
	end

  ##HELPERS
	def all_game_scores_by_team
		hash = Hash.new {|k, v| k[v] = []}
		@games.each do |game|
			hash[game.info[:home_team_id]] << game.info[:home_goals]
			hash[game.info[:away_team_id]] << game.info[:away_goals]
		end
		hash
	end

	def win_or_loss(team_id, win_loss_string)
		opponent_games = games_of_opposite_team(team_id)
		opponent_results = opponent_game_results(opponent_games)
		opponent_results.each do |k,v|
			opponent_results[k] = (v.count(win_loss_string).to_f / v.count)
		end
		team_id = opponent_results.key(opponent_results.values.max)
		team_name_by_id(team_id)
	end

	def opponent_game_results(opponent_games)
		opponent_results = Hash.new {|k,v| k[v] = []}
		opponent_games.each do |game_id, game|
			opponent_results[game.info[:team_id]] << game.info[:result]
		end
		opponent_results
	end

	def games_of_opposite_team(team_id)
		all_games_by_team = games_by_team_id[team_id]
		opponent_games = {}
		all_games_by_team.each do |game|
			game = games_by_game_id[game.info[:game_id]].find {|element| element.info[:team_id] != team_id}
			opponent_games[game.info[:game_id]] = game
		end
		opponent_games
	end

  def season_win_percentage_by_team(team_id)
    games_played_by_team = games_played_by_season.dup
    games_played_by_team.each do |season, games|
      games_list = []
      games.each do |game|
        games_list << game if game.info[:home_team_id] == team_id.to_i || game.info[:away_team_id] == team_id.to_i
      end
      games_played_by_team[season] = win_percent_calculator(games_list, team_id)
    end
    #### NEXT BLOCK ACCOUNTS FOR SMALL SAMPLE SETS WHERE SEASONS HAVE NaN RESULTS
    games_played_by_team.each do |k, value|
      games_played_by_team[k] = 0 if value.nan?
    end
    ####
  end
  
  def win_percent_calculator(games_list, team_id)
    games_won = 0
    games_list.each do |game|
      if game.info[:away_team_id] == team_id.to_i
        games_won += 1 if game.info[:away_goals] > game.info[:home_goals]
      elsif game.info[:home_team_id] == team_id.to_i
        games_won += 1 if game.info[:away_goals] < game.info[:home_goals]
      end
    end
    (games_won.to_f / games_list.count).round(2)
  end
  
end