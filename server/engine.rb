# my_rack_app.rb
require 'rack'
require 'json'

GRID_SIZE = 100


def get_grid
  rand = Random.new
  grid = []
  for n in 0..GRID_SIZE
    grid << (rand.rand(1.0) < 0.5)
  end
  return grid
end

app = Proc.new do |env|
  ['200',
   {'Content-Type' => 'application/json'},
   [JSON.generate(get_grid())]
  ]
end

Rack::Handler::WEBrick.run app