require_relative "minesweeper_tile"

class Board

  attr_accessor :tiles, :game_over

  def initialize(height, width, mines)
    @tiles = Array.new(height) { Array.new(width) }
    @game_over = nil
    @mines = mines
    @flags_on_board = 0
    fill_board(mines)
  end

  def height
    @tiles.length
  end

  def width
    @tiles[0].length
  end

  def [](pos)
    row, col = pos
    @tiles[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @tiles[row][col] = value
  end

  def mine_count

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
    mines.times { |i| bombs[i] = true }
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
    when 'u'
      unflag(pos)
    else
      raise "Confused"
    end

    return if @game_over == :lost

    each_pos do |row, col|
      t = @tiles[row][col]
      if t.unexplored? && !t.is_bomb? && !t.flagged?
        return
      end
    end

    @game_over = :won
  end

  def check(pos)
    row, col = pos
    t = @tiles[row][col]
    if t.is_bomb?
      t.exploded!
      @game_over = :lost
      return
    end

    reveal(pos)
  end

  def reveal(pos)
    row, col = pos
    t = @tiles[row][col]
    t.revealed!
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
    tile.neighbors.map{ |p| @tiles[p[0]][p[1]] }
  end

  def flag(pos)
    unless @flags_on_board < @mines
      return
    end
    row, col = pos
    @tiles[row][col].flagged!
    @flags_on_board += 1
    check_flags if @flags_on_board == @mines
  end

  def check_flags
    each_pos do |row, col|
      t = @tiles[row][col]
      return if t.flagged? && !t.is_bomb?
    end

    @game_over = :won
  end

  def unflag(pos)
    if @flags_on_board == 0 || !@tiles[row][col].flagged?
      return
    end
    row, col = pos
    @tiles[row][col].unexplored!
    @flags_on_board -= 1
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

  def reveal_all
    each_pos do |row,col|
      t = @tiles[row][col]
      if t.is_bomb?
        t.exploded! if @game_over == :lost
        t.flagged! if @game_over == :won
      else
        reveal([row,col])
      end
    end

  end

end