module Adjacent

  ORTHOGONAL_DIRECTIONS = {
    r: [0, 1],
    l: [0, -1],
    u: [-1, 0],
    d: [1, 0],
  }.freeze

  DIAGONAL_DIRECTIONS = {
    ul: [-1, -1],
    ur: [-1, 1],
    dl: [1, -1],
    dr: [1, 1],
  }.freeze

  ADJACENT_DIRECTIONS = ORTHOGONAL_DIRECTIONS.merge(DIAGONAL_DIRECTIONS).freeze

  NEIGHBORHOOD_DIRECTIONS = ADJACENT_DIRECTIONS.merge(
    c: [0, 0],
  ).freeze

  ALL_DIRECTIONS = NEIGHBORHOOD_DIRECTIONS

  def orthogonally_adjacent(**opts)
    adjacent(ORTHOGONAL_DIRECTIONS.keys, **opts)
  end

  def diagonally_adjacent(**opts)
    adjacent(DIAGONAL_DIRECTIONS.keys, **opts)
  end

  def neighborhood(**opts)
    adjacent(NEIGHBORHOOD_DIRECTIONS.keys, **opts)
  end

  def adjacent(direction = ADJACENT_DIRECTIONS.keys, **opts)
    case self
    in [Integer, Integer]
      if direction.is_a?(Array)
        direction.map { _single_adjacent(_1, **opts) }
      else
        _single_adjacent(direction, **opts)
      end
    else
      abort "Can not only call orthogonally_adjacent on array with two integers"
    end
  end

  protected

  def _single_adjacent(dir, distance: 1)
    case dir
    when *ALL_DIRECTIONS.keys
      d = dir
    else
      d = dir.to_s.downcase[0].to_sym
    end
    dy, dx = ALL_DIRECTIONS[d]
    if dy && dx
      [self[0] + dy * distance, self[1] + dx * distance]
    else
      abort "Invalid direction for adjacency: #{dir.inspect}"
    end
  end

end
