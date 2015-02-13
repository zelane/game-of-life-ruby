require 'eventmachine'
require 'faye'
require 'json'

GRID_SIZE = 100
BASE_POP = 0.06


# TODO - move to engine.rb
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
        neighbours = [
            @grid[n][next_col],
            @grid[n][prev_col],
            @grid[prev_row][prev_col],
            @grid[prev_row][m],
            @grid[prev_row][next_col],
            @grid[next_row][prev_col],
            @grid[next_row][m],
            @grid[next_row][next_col],
        ]
        population = 0
        for nb in neighbours
          population += (nb ? 1 : 0)
        end
        if @grid[n][m]
          new_grid[n][m] = (population == 3 or population == 2)
        else
          new_grid[n][m] = (population == 3)
        end
      end
    end
    if @count % 50 == 0
        init_shape(random_shapes(1)[0], new_grid)
    end
    @grid = new_grid
    return @grid
  end

  def init_shape(shape, grid)
    for coords in shape
      grid[coords[0]][coords[1]] = true
    end
  end

  def init_grid(shapes)
    grid = []
    for n in 1..GRID_SIZE
      grid << []
      for m in 1..GRID_SIZE
        grid[n-1] << false
      end
    end
    for shape in shapes
      init_shape(shape, grid)
    end
    return grid
  end
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

def run_it(client)
  while true
    client.publish('/yo', 'SERVER');
    sleep(0.3)
  end
end

EventMachine.run {
  client = Faye::Client.new('http://172.30.152.64:8080/faye')
  # init_shapes = [ShapeMaker.glider(0, 0), ShapeMaker.send('toad', 50, 50)]
  init_shapes =
  gol = GameOfLife.new(shapes=random_shapes(8))
  client.subscribe('/yo') do |message|
    client.publish('/foo', gol.get_grid())
  end
  #run_it(client)
}