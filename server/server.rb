require 'faye'

Faye::WebSocket.load_adapter('thin')

bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)

bayeux.on(:handshake) do |client_id|
  puts "HANDSHAKE WITH #{client_id}"
end
bayeux.on(:subscribe) do |client_id, channel|
  puts "SUBSCRIBE BY #{client_id} TO #{channel}"
end
bayeux.on(:unsubscribe) do |client_id, channel|
  puts "UN-SUBSCRIBE BY #{client_id} TO #{channel}"
end
bayeux.on(:publish) do |client_id, channel, data|
  puts "PUBLISH BY #{client_id} TO #{channel} DATA #{data}"
end

l = {:Host => '172.30.152.64'}

Rack::Handler::Thin.run(bayeux, options=l)