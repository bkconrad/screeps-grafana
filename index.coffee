###
hopsoft\screeps-statsd

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Bryan Conrad <bkconrad@gmail.com>
@copyright  2016 Bryan Conrad
@link       https://github.com/hopsoft/docker-graphite-statsd
@license    http://choosealicense.com/licenses/MIT  MIT License
###

# Application's initialisation and startup script
ScreepsStatsd = require './src/ScreepsStatsd'
(new ScreepsStatsd).run()