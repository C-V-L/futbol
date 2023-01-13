module Sortable

	def games_played_by_season
		@games_played_by_season ||= games.group_by do |game|
			game.info[:season]
		end
  end

	def games_by_game_id
		@games_by_game_id ||= game_teams.group_by do |game_team|
			game_team.info[:game_id]
		end
	end

	def games_by_team_id
		@games_by_team_id ||= game_teams.group_by do |game_team|
			game_team.info[:team_id] 
		end
	end

	def find_team_by_id
		@find_team_by_id ||= teams.group_by do |team|
			team.info[:team_id]
		end
	end

	def team_name_by_id(id)
		find_team_by_id[id].first.info[:team_name]
	end


	def game_ids_for_season(season_id)
		games = games_played_by_season[season_id.to_i]
		games.map do |game|
			game.info[:game_id]
		end
  end
end