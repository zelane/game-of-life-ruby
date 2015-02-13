class GameOfLife

  def initialize(shapes=NIL)
    @count = 0
    @grid = init_grid(shapes)
  end

  def count
    return @count
  end

  def get_grid
    @count += 1
    if @count < 2
      return @grid
    end
    new_grid = []
    for n in 0..GRID_SIZE-1
      new_grid << []
      for m in 0..GRID_SIZE-1
        next_col = (m + 1) % GRID_SIZE
        prev_col = (m - 1) % GRID_SIZE
        next_row = (n + 1) % GRID_SIZE
        prev_row = (n - 1) % GRID_SIZE

        population = 0
        population += @grid[n][next_col]
        population += @grid[n][prev_col]
        population += @grid[prev_row][prev_col]
        population += @grid[prev_row][m]
        population += @grid[prev_row][next_col]
        population += @grid[next_row][prev_col]
        population += @grid[next_row][m]
        population += @grid[next_row][next_col]

        new_grid[n][m] = (population == 3 or (population == 2 and @grid[n][m] == 1)) ? 1 : 0
      end
    end
    # Random periodic spawn
    if @count % SPAWN_RATE == 0
      init_shape(random_shapes(1)[0], new_grid)
    end
    @grid = new_grid
    return @grid
  end

  def init_shape(shape, grid)
    for coords in shape
      grid[coords[0]][coords[1]] = 1
    end
  end

  def init_grid(shapes)
    grid = []
    for n in 1..GRID_SIZE
      grid << []
      for m in 1..GRID_SIZE
        grid[n-1] << 0
      end
    end
    for shape in shapes
      init_shape(shape, grid)
    end
    return grid
  end
end

def random_shapes(num)
  r = Random.new
  safe = 4
  options = ['toad', 'beacon', 'lightweight_spaceship', 'blinker', 'glider']
  shapes = []
  for n in 1..num
    obj = options[r.rand(options.length)]
    shapes << ShapeMaker.send(obj, r.rand(GRID_SIZE-safe),r.rand(GRID_SIZE-safe))
  end
  return shapes
end

class ShapeMaker
  def self.glider(x, y)
    return [
        [x, y],
        [x, y+1],
        [x, y+2],
        [x+1, y],
        [x+2, y+1]
    ]
  end

  def self.blinker(x, y)
    return [
        [x, y],
        [x, y+1],
        [x, y+2]
    ]
  end

  def self.beacon(x, y)
    return [
        [x, y],
        [x, y+1],
        [x+1, y],
        [x+2, y+3],
        [x+3, y+2],
        [x+3, y+3]
    ]
  end

  def self.lightweight_spaceship(x, y)
    return [
        [x, y+2],
        [x, y+3],
        [x+1, y],
        [x+1, y+1],
        [x+1, y+3],
        [x+1, y+4],
        [x+2, y],
        [x+2, y+1],
        [x+2, y+2],
        [x+2, y+3],
        [x+3, y+1],
        [x+3, y+2]
    ]
  end

  def self.toad(x, y)
    return [
        [x, y+1],
        [x, y+2],
        [x, y+3],
        [x+1, y],
        [x+1, y+1],
        [x+1, y+2]
    ]
  end
end
