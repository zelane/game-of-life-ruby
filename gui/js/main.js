$(document).ready(function(){
	init();	
})

Array.prototype.clone = function() {
	return this.slice(0);
};

var self = this;
var canvas, context;
var grid_size = 800;
var block_size = 10;
var block_count = grid_size / block_size;
var colours = {}
var step_duration = 0.1;
var old_data;

function init(){	
	grab_colours();
    canvas = document.getElementById("canvas");
	context = canvas.getContext('2d');
	update_data();
	setInterval(function(){
		update_data();
	}, step_duration * 1000);
}

function update_data(){
	context.clearRect(0, 0, grid_size, grid_size);
	draw_square(0, 0, grid_size, colours['background']);
	draw_data(gen_data());
}

function draw_data(data){
	for(var c = 0; c < data.length; c += 1){
		var column = data[c];
		for(var r = 0; r < column.length; r += 1){
			var cell = column[r];
			if(cell){
				draw_block(c, r);
			}
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
		colours[dom.data('tag')] = dom.css("background-color");
	});
}

function rgba(r, g, b, a){
	return "rgba(" + r + ", " + g + ", " + b + ", " + a + ")";
}

function draw_grid(){
	for (var x = 0.5; x <= grid_size; x += block_size) {
		context.moveTo(x, 0);
		context.lineTo(x, grid_size);
	}
	for (var y = 0.5; y <= grid_size; y += block_size) {
		context.moveTo(0, y);
		context.lineTo(grid_size, y);
	}	
	context.strokeStyle = colours['grid'];
	context.stroke();
}

function draw_block(col, row){
	var x = col * block_size;
	var y = row * block_size;
	draw_square(x, y, block_size, colours['block']);
}

function clear_block(x, y){
	context.clearRect(x, y, block_size, block_size);
	draw_square(x, y, block_size, colours['background']);
}

function draw_square(x, y, size, colour){
    context.fillStyle = colour;
	context.fillRect(x, y, size, size);	
}