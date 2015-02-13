$(document).ready(function(){
	init();	
})

Array.prototype.clone = function() {
	return this.slice(0);
};

var self = this;
var canvas, context;
var block_size = 8;
var block_count = 1;
var colours = {};
var t = 300;
var render_int;
var client;

function init(){
	grab_colours();
	client = new Faye.Client('http://172.30.152.64:8080/faye');
    canvas = new fabric.Canvas('canvas', {
    	renderOnAddRemove: false,
    	stateful: false
    });
	context = canvas.getContext('2d');
    client.subscribe('/config', function(data){
    	console.log(data);
    	block_count = data['grid_size'];
    	t = data['interval'] * 1000;
    	init_rects();
	    client.subscribe('/grid', function(data){
			draw_data(data);
	    });
    });
}

function three(){
	var scene = new THREE.Scene();
	var camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );
	var renderer = new THREE.WebGLRenderer();
	renderer.setSize( window.innerWidth, window.innerHeight );
	document.body.appendChild( renderer.domElement );
	var material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } );
	
	var geometry = new THREE.BoxGeometry( 1, 1, 1 );
	var cube = new THREE.Mesh( geometry, material );
	scene.add( cube );

	var geometry = new THREE.BoxGeometry( 1, 1, 1 );
	var cube = new THREE.Mesh( geometry, material );
	scene.add( cube );

	camera.position.z = 5;
	function render() {
		requestAnimationFrame( render );
		renderer.render( scene, camera );
	}
	render();
}

function init_rects(){
	canvas.clear();
	var c = block_count - 1;
	for(c; c != 0; c--){
		var r = block_count - 1;
		for(r; r != 0; r--){
			var rect = new fabric.Rect({
				left: c * block_size,
				top: r * block_size,
				fill: 'red',
				width: block_size,
				height: block_size,
				selectable: false,
				opacity: 0
			})
			canvas.add(rect);
		}
	}
	canvas.renderAll();
}

function draw_data(data){
	var i = 0;
	var c = block_count - 1;
	for(c; c != 0; c--){
		var r = block_count - 1;		
		for(r; r != 0; r--){
			var state = data[c][r];
			var rect = canvas.item(i);
			if(state){
				rect.set({
					fill: colours['block'].toHexString(),
					opacity: 1
				})
				// rect.animate('opacity', 1, {
				// 	duration: t / 5,
			 //  		// easing: fabric.util.ease.easeInCubic
				// }); 
			}
			else{
				rect.set({
					opacity: 0
				})
				// rect.animate('opacity', 0, {
				// 	duration: t * 0.8
				// }); 
			}
			i++;
		}
		colours['block'] = tinycolor(colours['block']).spin(10);
	}
	// clearInterval(render_int);
	// render_int = setInterval(function(){
	// 	canvas.renderAll()
	// }, t / 10);
	canvas.renderAll();
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