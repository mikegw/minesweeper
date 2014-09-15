require_relative 'minesweeper_board'

class Game

  attr_reader :board

  def initialize(height = 8, width = 8, mines = 10)
    @board = Board.new(height, width, mines)
  end

  def play
    until @board.over?
      system('clear')
      @board.show_board
      move, pos = get_move
      @board.make_move(move, pos)
    end
    game_over
  end

  def get_move
    puts "Please enter a move:"
    input = gets.chomp
    parsed = input.scan(/[rf\d]+/)
    move = [parsed.first, parsed.drop(1).map(&:to_i)]
  end

  def game_over
    system('clear')
    @board.reveal_all
    @board.show_board
    case @board.game_over
    when :won
      puts "Aaaaah, you won!!!"
    when :lost
      puts "Game over, sucker!"
    end
  end


end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end
