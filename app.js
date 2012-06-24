// node-hakoniwa

var fs=require('fs'), express=require('express'), coffee=require('coffee-script');

var config=require('./config.js');

//根幹の処理
var gameprocess=null
// Coffeeのファイル
var files=["process","islands","lands","gameconfig"], count=0;
files.forEach(function(filename){
	fs.readFile("./"+filename+".coffee","utf8",function(err,data){
		if(err){
			throw err;
		}
		fs.writeFile("./tmp/"+filename+".js",coffee.compile(data),function(err){
			if(err)throw err;
			console.log("Compiled "+filename+".coffee");
			if(++count >= files.length){
				//全てのコンパイルが完了
				gameprocess=require('./tmp/process');
				gameprocess.emit("init");
			}
		});
	});
});
var app=express.createServer();
app.get('/images/*',function(req,res){
	res.sendfile("images/"+req.params[0]);
});
app.get('/sight/:id',function(req,res){
	gameprocess.emit("sight",req.params.id,function(html){
		res.contentType("text/html");
		res.send(html); 
	});
});
app.get('*',function(req,res){
	res.send("hi");
});

app.listen(config.server.port);
