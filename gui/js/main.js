$(document).ready(function(){
	init();	
});

var self = this;
var block_size = 8;
var block_count = 1;
var colours = {};
var interval = 300;
var client;

var stage;
var graphics;
var inited = false;

function init(){
	three();
	grab_colours();
	client = new Faye.Client('http://172.30.152.64:8080/faye');
    client.subscribe('/config', function(data){
    	if(!inited){    		
			block_count = data['grid_size'];
			interval = data['interval'] * 1000;
			inited = true;
    	}
    });
    client.subscribe('/grid', function(data){
		draw_data(data);
    });
}

function three(){
	stage = new PIXI.Stage(0x333333);
	var renderer = PIXI.autoDetectRenderer(800, 800);

	$('#wrapper').append(renderer.view);

	requestAnimFrame(animate);
	graphics = new PIXI.Graphics();
	stage.addChild(graphics);
	stage.addChild(graphics);

	function animate(){
	    requestAnimFrame(animate);
	    renderer.render(stage);
	}
}

function draw_block(x, y, color){
	graphics.beginFill(color, 1);
	graphics.lineStyle(1, 0x111111, 1);
	graphics.drawRect(x, y, block_size, block_size);
}

function draw_data(data){
	graphics.clear();
	var c = block_count - 1;
	var colour = colours['block'];
	var i = 0;
	for(c; c != 0; c--){
		var r = block_count - 1;		
		for(r; r != 0; r--){
			if(data[c][r]){
				draw_block(c*block_size, r*block_size, "0x" + colour.toHex());
			}
			i++;
		}
		if(i % 20){
			colour = tinycolor(colour).spin(23);	
		}
	}
}

function gen_data(){
	var cols = [];
	for(var col = 0; col <= block_count; col += 1){
		var rows = [];
		for(var row = 0; row <= block_count; row += 1){
			rows.push(true_or_false());
		}
		cols.push(rows);
	}
	return cols;
}

function true_or_false(){
	return Math.random() < 0.1 ? true : false;
}

function grab_colours(){
	$(".colour").each(function(x, i){
		var dom = $(i);
		colours[dom.data('tag')] = tinycolor(dom.css("background-color"));
	});
}