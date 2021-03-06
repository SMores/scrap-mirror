require('coffee-script/register');

var express = require('express')
    , app = express()
    , server = require('http').createServer(app)
    , io = require('socket.io')(server)
    , port = (process.env.PORT || 9001)
    , db = require('./models')
    , coffeeMiddleware = require('coffee-middleware')
    , SequelizeStore = require('connect-session-sequelize')(express.session.Store);
//Setup Express
server.listen(port);

app.configure(function(){
    app.set('views', __dirname + '/views');
    app.set("view engine", "jade");
    app.set('view options', { layout: false });
    app.use(express.static(__dirname + '/client'));
    app.use(express.bodyParser());
    app.use(express.cookieParser());
    app.use(express.session({
        secret: "club_sexdungeon",
        store: new SequelizeStore({
            db: db.sequelize
        })
    }));
    
    app.use(coffeeMiddleware({
        src: __dirname + '/client',
        compress: true,
        encodeSrc: false,
        force: true,
        debug: true,
        bare: true
    }));
});

AWS_ACCESS_KEY = 'AKIAJKOD56YSMVDFPX7Q'//process.env.AWS_ACCESS_KEY;
AWS_SECRET_KEY = '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'//process.env.AWS_SECRET_KEY;
S3_BUCKET = 'scrap_images'//process.env.S3_BUCKET;

db.sequelize.sync({ force: false }).complete(function(err) {
    if (err) {
        throw err[0];
    } else {
        require('./server/socketListeners')(io);
        require('./server/routes')(app);
        console.log('Listening on port:' + port );
    }
});
