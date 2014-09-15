class Tile

  STATUS_ARR = [:unexplored, :bombed, :flagged, :revealed]

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
  end

  def method_missing(new_status)
    new_status_string = new_status.to_s
    if new_status_string[-1] == '?'
      status_query = new_status_string[0..-2].to_sym
      raise StandardError unless STATUS_ARR.include?(status_query)
      return status_query == @status
    end

    raise StandardError, new_status.to_s unless STATUS_ARR.include?(new_status)

    @status = new_status
  end

  def trim_neighbors(height, width)
    @neighbors.keep_if do |pos|
      pos.first.between?(0, height - 1) && pos.last.between?(0, width - 1)
    end
  end

end

class Board

  def initialize(height, width)
    @board = Array.new(height) { Array.new(width) }
    @height, @width = height, width
  end

  def fill_board
    each_pos do |row, col|
      @board[row][col] = Tile.new([row, col])
      @board[row][col].trim_neighbors(@height, @width)
    end
  end

  def each_pos(&prc)
    @board.each_with_index do |row, row_index|
      row.each_with_index do |el, col_index|
        prc.call(row_index, col_index)
      end
    end
  end

  def make_move(pos)

  end
end