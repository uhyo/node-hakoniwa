// node-hakoniwa

var fs=require('fs'), express=require('express');

var config=require('./config.js');

//根幹の処理
var gameprocess=new (require('./ts/process').Process);
var app=express();
/*app.get('/images/*',function(req,res){
	res.sendfile("images/"+req.params[0]);
});*/
app.use("/images",express.static(__dirname+"/images"));
app.get('/sight/:id',function(req,res){
	gameprocess.sight(req.params.id,function(err,html){
		if(err){
			res.set("Content-Type","text/plain");
			res.status(404).send(err.message || err);
			return;
		}
		res.set("Content-Type","text/html");
		res.send(html); 
	});
});
app.get('*',function(req,res){
	res.send("hi");
});

app.listen(config.server.port);
