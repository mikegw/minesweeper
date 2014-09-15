class Tile

  STATUS_HASH = {unexplored: "\u{25A1}",
                bombed: "\u{1F4A3}",
                flagged:"\u{2691}",
                revealed: ' '}

  attr_accessor :neighbors, :adjacent_bomb_count

  def initialize(pos)
    @row, @col = pos
    @status = :unexplored
    @neighbors = [[@row - 1, @col - 1],
                   [@row - 1, @col],
                   [@row - 1, @col + 1],
                   [@row, @col - 1],
                   [@row, @col + 1],
                   [@row + 1, @col - 1],
                   [@row + 1, @col],
                   [@row + 1, @col + 1]]
    @adjacent_bomb_count = 0
    @is_bomb = false
  end

  def method_missing(new_status)
    new_status_string = new_status.to_s
    if new_status_string[-1] == '?'
      status_query = new_status_string[0..-2].to_sym
      raise StandardError unless STATUS_HASH.has_key?(status_query)
      return status_query == @status
    end

    raise StandardError, new_status.to_s unless STATUS_HASH.has_key?(new_status)

    @status = new_status
  end

  def trim_neighbors(height, width)
    @neighbors.keep_if do |pos|
      pos.first.between?(0, height - 1) && pos.last.between?(0, width - 1)
    end
  end

  def to_s
    return @adjacent_bomb_count.to_s if @adjacent_bomb_count > 0
    STATUS_HASH[@status]
  end

  def is_bomb?
    @is_bomb
  end

  def arm_bomb
    @is_bomb = true
  end
end

class Board

  attr_accessor :tiles

  def initialize(height, width, mines)
    @tiles = Array.new(height) { Array.new(width) }
    @height, @width = height, width
    @game_over = false
    fill_board(mines)
  end

  def over?
    @game_over
  end

  def fill_board(mines)
    each_pos do |row, col|
      @tiles[row][col] = Tile.new([row, col])
      @tiles[row][col].trim_neighbors(@height, @width)
    end

    place_mines(mines)
  end

  def place_mines(mines)
    bombs = Array.new(@width * @height, false)
    mines.times {|i| bombs[i] = true}
    bombs.shuffle!

    each_pos do |row, col|
      @tiles[row][col].arm_bomb if bombs.pop
    end
  end

  def each_pos(&prc)
    @tiles.each_with_index do |row, row_index|
      row.each_with_index do |el, col_index|
        prc.call(row_index, col_index)
      end
    end
  end

  def make_move(move, pos)
    case move
    when 'r'
      check(pos)
    when 'f'
      flag(pos)
    else
      #stuff
    end
  end

  def check(pos)
    row, col = pos
    t = @tiles[row][col]
    if t.is_bomb?
      t.bombed
      @game_over = true
      return
    end

    reveal(pos)
  end

  def reveal(pos)
    row, col = pos
    t = @tiles[row][col]
    t.revealed
    bomb_count = get_neighbors(t).count(&:is_bomb?)
    if bomb_count > 0
      t.adjacent_bomb_count = bomb_count
    else
      t.neighbors.each do |neighbor_pos|
        next unless @tiles[neighbor_pos[0]][neighbor_pos[1]].unexplored?
        reveal(neighbor_pos)
      end
    end

    nil
  end

  def get_neighbors(tile)
    tile.neighbors.map{|p| @tiles[p[0]][p[1]]}
  end

  def flag(pos)
    row, col = pos
    @tiles[row][col].flagged
  end

  def show_board
    puts "  " + (0...@width).to_a.join(" ")
    @tiles.each_with_index do |row,i|
      print i.to_s + " "
      row.each do |tile|
        print tile.to_s + ' '
      end
      puts
    end

    nil
  end

  def game_over
    each_pos do |row,col|
      t = @tiles[row][col]
      if t.is_bomb?
        t.bombed
      else
        reveal([row,col])
      end
    end

  end

end

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
    @board.game_over
    @board.show_board
  end


end

if __FILE__ == $PROGRAM_NAME
  game = Game.new
  game.play
end
