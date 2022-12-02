require_relative './solve'

EXAMPLE = <<-END
A Y
B X
C Z
END

class RockPaperScissorsTournament

  attr_reader :strategy

  def initialize(lines)
    @strategy = lines.map do |line|
      line.tr("ABCXYZ", "012012").split.map_i
    end
  end

  def score
    strategy.map do |opp_choice, my_choice|
      selection_score = my_choice + 1
      outcome_score = ((my_choice - opp_choice + 1) * 3) % 9

      selection_score + outcome_score
    end.sum
  end

end

class RockPaperScissorsTournamentFixed < RockPaperScissorsTournament

  def strategy
    super.map do |opp_choice, desired_result|
      my_choice = (opp_choice + desired_result - 1) % 3
      [opp_choice, my_choice]
    end
  end

end

solve_with(RockPaperScissorsTournament, EXAMPLE => 15) do |tournament|
  tournament.score
end

solve_with(RockPaperScissorsTournamentFixed, EXAMPLE => 12) do |tournament|
  tournament.score
end
