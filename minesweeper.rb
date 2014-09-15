require 'yaml'
require_relative 'minesweeper_board'

class Game

  attr_reader :board

  def initialize(height = 16, width = 16, mines = 20)
    @board = Board.new(height, width, mines)
  end

  def play
    print "(N)ew game or (L)oad game? "
    option = gets.chomp.downcase
    if option == 'l'
      Dir.foreach("saves") { |savefile| puts savefile }
      print "Select a file: "
      @board = load_game("./saves/" + gets.chomp)
    end
    @start_time = Time.now
    until @board.game_over?
      system('clear')
      @board.show_board
      move, pos = get_move
      @board.make_move(move, pos)
      @board.moves += 1
    end
    game_over
    end_time = Time.now - @start_time
    puts "Game lasted #{end_time}s in #{@board.moves} moves."
  end

  def get_move
    puts "Please enter a command:"
    input = gets.chomp
    if input == 'save'
      print "Enter a filename: "
      save_game("./saves/" + gets.chomp)
    elsif input == 'quit'
      exit
    end

    parsed = input.scan(/[rfu\d]+/)
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

  def save_game(filename)
    @board.play_time += Time.now - @start_time
    File.open(filename, 'w+') do |file|
      file.puts @board.to_yaml
    end
    exit
  end

  def load_game(filename)
    YAML::load(File.readlines(filename).join)
  end

end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end
