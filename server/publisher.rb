require 'eventmachine'
require 'faye'
require 'json'

require './engine.rb'

INTERVAL = 0.33 # Generation life in seconds
GRID_SIZE = 100 # In cells
SPAWN_RATE = 100 # New random shape every n generations

def pub_config(client, gol)
  client.publish('/config', {
    :grid_size => GRID_SIZE,
    :interval => INTERVAL,
    :generation => gol.count
  })
end

def pub_grid(client, gol)
  client.publish('/grid', gol.get_grid())
end

EM.run do
  init_shapes = (GRID_SIZE / 10).ceil
  gol = GameOfLife.new(shapes=random_shapes(init_shapes))
  client = Faye::Client.new('http://172.30.152.64:8080/faye')
  pub_config(client, gol)
  pub_grid(client, gol)
  EM.add_periodic_timer(10) {
    pub_config(client, gol)
  }
  EM.add_periodic_timer(INTERVAL) {
    pub_grid(client, gol)
  }
end
