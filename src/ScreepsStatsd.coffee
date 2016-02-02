###
hopsoft\screeps-statsd

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Bryan Conrad <bkconrad@gmail.com>
@copyright  2016 Bryan Conrad
@link       https://github.com/hopsoft/docker-graphite-statsd
@license    http://choosealicense.com/licenses/MIT  MIT License
###

###
SimpleClass documentation

@since  0.1.0
###
rp = require 'request-promise'
zlib = require 'zlib'
require('request-debug')(rp)
StatsD = require 'node-statsd'
class ScreepsStatsd

  ###
  Do absolutely nothing and still return something

  @param    {string}    string      The string to be returned - untouched, of course
  @return   string
  @since    0.1.0
  ###
  run: ( string ) ->
    rp.defaults jar: true
    @loop()
    setInterval @loop, 10000

  loop: () =>
    @signin()

  signin: () =>
    @client = new StatsD host: process.env.GRAPHITE_PORT_8125_UDP_ADDR
    options =
      uri: 'https://screeps.com/api/auth/signin'
      json: true
      method: 'POST'
      body:
        email: process.env.SCREEPS_EMAIL
        password: process.env.SCREEPS_PASSWORD
    rp(options).then (x) =>
      @token = x.token
      @getMemory()

  getMemory: () =>
    options =
      uri: 'https://screeps.com/api/user/memory'
      method: 'GET' 
      json: true
      headers:
        "X-Token": @token
        "X-Username": process.env.SCREEPS_USERNAME
      qs:
        path: 'stats'
    rp(options).then (x) =>
      # yeah... dunno why
      return unless x.data
      data = x.data.split('gz:')[1]
      finalData = JSON.parse zlib.gunzipSync(new Buffer(data, 'base64')).toString()
      @report(finalData)

  report: (data) =>
    console.log data
    for k,v of data
      console.log k,v
      @client.gauge k, v

module.exports = ScreepsStatsd
