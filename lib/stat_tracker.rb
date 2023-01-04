require 'csv'

class StatTracker
	attr_reader :games,
							:teams,
							:game_teams

	def initialize(games, teams, game_teams)
		@games = games
		@teams = teams
		@game_teams = game_teams
	end

	def self.from_csv(multiple_data_paths) # in hash format
		games_data = CSV.read multiple_data_paths[:games], headers: true, header_converters: :symbol
		teams_data = CSV.read multiple_data_paths[:teams], headers: true, header_converters: :symbol
		game_teams_data = CSV.read multiple_data_paths[:game_teams], headers: true, header_converters: :symbol
		StatTracker.new(games_data, teams_data, game_teams_data)
	end

	def find_all_game_id
		@games.map do |row|
			row[:game_id]
		end
	end

	def total_scores
		@games.map do |row|
			row[:away_goals].to_i + row[:home_goals].to_i
		end
	end

	def highest_total_score
		total_scores.max
	end

	def lowest_total_score
		total_scores.min
	end

  def all_team_names
    teams = []
    @teams.map do |row|
      teams << row[:teamName]
    end
  end

  def count_of_teams
    all_team_names.count
  end

  def average_goals_per_game
    average_score = total_scores.sum.to_f / total_scores.count
    average_score.round(3)
  end

  def average_win_percentage(team_id)
    games_played = []
    games_won = []

    @game_teams.each do |row|
      if row[:team_id].to_i == team_id
        games_played << row[:game_id]
      end
    end
    @game_teams.map do |row|
      if row[:team_id].to_i == team_id && row[:result] == "WIN"
        games_won << row[:game_id]
      end
    end
    win_percentage = games_won.count.to_f / games_played.count
    win_percentage.round(3)
  end
end
