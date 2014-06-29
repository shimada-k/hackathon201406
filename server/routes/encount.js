var express = require('express');
var socket  = require('socket.io');
var router = express.Router();

//var server = module.parent.exports.set('server');
//var io = socket.listen(server);

/* GET users listing. */
router.get('/', function(req, res) {
    //io.sockets.emit('image:receive', data);
    console.log(req.query.proximity);
    //io.sockets.emit('message:receive', req.query.proximity);
    io.sockets.emit('message:receive', req.query.proximity, 1198734575);
});

module.exports = router;

//var express = require('express');
//var router = express.Router();

/* GET users listing. */
//router.get('/', function(req, res) {
//  console.log('encount');
//  res.send('respond with a resource');
//});

//module.exports = router;
