require_relative "minesweeper_tile"

class Board

  attr_accessor :tiles, :game_over, :play_time, :moves

  def initialize(height, width, mines, play_time = 0, moves = 0)
    @tiles = Array.new(height) { Array.new(width) }
    @play_time = play_time
    @moves = moves
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
    count = 0
    each_pos do |pos|
      count += 1 if self[pos].is_bomb?
    end

    count
  end

  def flag_count
    count = 0
    each_pos do |pos|
      count += 1 if self[pos].flagged?
    end

    count
  end

  def fill_board(mines)
    each_pos do |pos|
      self[pos] = Tile.new(pos)
      self[pos].trim_neighbors(height, width)
    end

    place_mines(mines)
  end

  def place_mines(mines)
    bombs = Array.new(self.height * self.width, false)
    mines.times { |i| bombs[i] = true }
    bombs.shuffle!

    each_pos do |pos|
      self[pos].arm_bomb if bombs.pop
    end
  end

  def each_pos(&prc)
    @tiles.each_with_index do |row, row_index|
      row.each_with_index do |el, col_index|
        prc.call([row_index, col_index])
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

  end

  def game_over?
    self.outcome
  end

  def outcome
    return :lost if self.tripped_mine?
    return :won if self.flagged_all_mines?
    return if self.moves_available?

    :won
  end

  def tripped_mine?
    each_pos do |pos|
      t = self[pos]
      return true if t.exploded?
    end

    false
  end

  def flagged_all_mines?
    each_pos do |pos|
      t = self[pos]
      return false if (t.flagged? && !t.is_bomb?) || (!t.flagged? && t.is_bomb?)
    end

    true
  end

  def moves_available?
    each_pos do |pos|
      t = self[pos]
      if t.unexplored? && !t.is_bomb? && !t.flagged?
        return true
      end
    end

    false
  end


  def check(pos)
    t = self[pos]
    if t.is_bomb?
      t.exploded!
      return
    end

    reveal(pos)
  end

  def reveal(pos)
    t = self[pos]
    t.revealed!
    bomb_count = get_neighbors(t).count(&:is_bomb?)
    if bomb_count > 0
      t.adjacent_bomb_count = bomb_count
    else
      t.neighbors.each do |neighbor_pos|
        next unless t = self[neighbor_pos].unexplored?
        reveal(neighbor_pos)
      end
    end

    nil
  end

  def get_neighbors(tile)
    tile.neighbors.map{ |p| self[p] }
  end

  def flag(pos)
    unless flag_count < mine_count
      return
    end
    self[pos].flagged!
  end

  def unflag(pos)
    if flag_count == 0 || !self[pos].flagged?
      return
    end
    self[pos].unexplored!
  end

  def show_board
    puts "   " + (0...self.width).to_a.map{ |i| '%2.2s' % i.to_s }.join()
    puts "    " + "_" * (2*self.width - 1)
    @tiles.each_with_index do |row,i|
      print '%2.2s' % i.to_s + " |"
      row.each_with_index do |tile, i |
        print tile.to_s
        print ' ' unless i == row.length - 1
      end
      print "|"
      puts
    end
    puts "    " + "\u{203E}" * (2*self.width - 1)
    nil
  end

  def reveal_all
    outcome = self.outcome
    each_pos do |pos|
      t = self[pos]
      if t.is_bomb?
        t.exploded! if outcome == :lost
        t.flagged! if outcome == :won
      else
        reveal(pos)
      end
    end

    nil
  end

end