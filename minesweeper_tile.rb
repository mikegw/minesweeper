class Tile

  STATUS_HASH = {unexplored: "\u{25A1}",
                exploded: "\u{1F4A3}",
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
    elsif new_status_string[-1] == '!'
      status_command = new_status_string[0..-2].to_sym
      raise StandardError unless STATUS_HASH.has_key?(status_command)
      @status = status_command
    end

    nil
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