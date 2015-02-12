require 'eventmachine'
require 'faye'
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

while true
  EM.run {
    client = Faye::Client.new('http://172.30.152.64:8080/faye')
    client.publish('/foo', get_grid())
    client.disconnect()
  }
  sleep(1)
end