## Rails Pub/Sub with Node, Redis & Socket.io

This very simple example app allows users to receive messages from the rails app in real time. It's basic proof of concept, but de-mystified the process for me.

It uses redis's pub/sub system to relay data between the rails app and the node server.  The node server publishes the data to subscribers using socket.io.

### Setup

Install redis

	brew install redis

Install node.js

    brew install node

Install node packages: express, redis, socket.io

    $ cd node && npm install
    
Setup the rails db:

	rake db:migrate

### Startup

Start rails as usual.

Start node server:

    node node/server.js

### See it do stuff
Open a couple of web browsers at [http://localhost:3000/notifications](http://localhost:3000/notifications)

Create a notification, and see it appear in the other browser.

##### From the Rails Console
Publish to all subscribers:

	$redis.publish('notifications.create', Notification.new(message: "yo, what up!").to_json)

### Relevant Code

##### app/controllers/notifications_controller.rb

	def create
	  @notification = Notification.new(params[:notification])
	
	  if @notification.save
	    $redis.publish('notifications.create', @notification.to_json)
	    redirect_to @notification, notice: 'Notification was successfully created.'
	  else
	    render action: "new"
	  end
	end

##### node/server.js
	
	io.sockets.on('connection', function (socket) {
	
	  // subscribe to redis
	  var subscribe = redis.createClient();
	  subscribe.subscribe('notifications.create');
	
	  // relay redis messages to connected socket
	  subscribe.on("message", function(channel, message) {
	    console.log("from rails to subscriber:", channel, message);
	    socket.emit('message', message)
	  });
	
	  // unsubscribe from redis if session disconnects
	  socket.on('disconnect', function () {
	    console.log("user disconnected");
	
	    subscribe.quit();
	  });
	
	});

##### app/views/notifications/index.html.erb
	var socket = io.connect('//localhost:3001/');
	
	socket.on('message', function (data) {
	  // do stuff with the data
	});