###
hopsoft\screeps-statsd

Licensed under the MIT license
For full copyright and license information, please see the LICENSE file

@author     Bryan Conrad <bkconrad@gmail.com>
@copyright  2016 Bryan Conrad
@link       https://github.com/hopsoft/docker-graphite-statsd
@license    http://choosealicense.com/licenses/MIT  MIT License
###

module.exports = ( grunt ) ->

  ### ALIASES ###

  jsonFile =                      grunt.file.readJSON           # Read a json file
  define =                        grunt.registerTask            # Register a local task
  log =                           grunt.log.writeln             # Write a single line to STDOUT


  ### GRUNT CONFIGURATION ###

  config =

    # Define aliases for known fs locations
    srcDir:                       'src/'              # CoffeeScript or other source files to be compiled or processed
    tstDir:                       'test/'             # Project's tests
    resDir:                       'res/'              # Static resources - images, text files, external deps etc.
    docDir:                       'docs/'             # Automatically-generated or compiled documentation
    srcFiles:                     ['<%= srcDir %>**/*.coffee', 'index.coffee']
    tstFiles:                     '<%= tstDir %>**/*.test.coffee'
    pkg:                          jsonFile 'package.json'


    ### TASKS DEFINITION ###

    # grunt-contrib-watch: Run tasks on filesystem changes
    watch:
      options:
        # Define default tasks here, then point targets' "tasks" attribute here: '<%= watch.options.tasks %>'
        tasks:                    ['lint', 'test']    # Run these tasks when a change is detected
        interrupt:                true                # Restarts any running tasks on next event
        atBegin:                  true                # Runs all defined watch tasks on startup
        dateFormat:               ( time ) -> log "Done in #{time}ms"

      # Targets

      gruntfile:                  # Watch the gruntfile for changes ( also dynamically reloads grunt-watch config )
        files:                    'gruntfile.coffee'
        tasks:                    '<%= watch.options.tasks %>'

      project:                    # Watch the project's source files for changes
        files:                    ['<%= srcFiles %>', '<%= tstFiles %>']
        tasks:                    '<%= watch.options.tasks %>'


    # grunt-coffeelint: Lint CoffeeScript files
    coffeelint:
      options:                    jsonFile 'coffeelint.json'

      # Targets

      gruntfile:                  'gruntfile.coffee'                          # Lint this file
      project:                    ['<%= srcFiles %>', '<%= tstFiles %>']      # Lint application's project files


    # grunt-mocha-cli: Run tests with Mocha framework
    mochacli:
      options:
        reporter:                 'spec'                                      # This report is nice and human-readable
        require:                  ['should']                                  # Run the tests using Should.js
        compilers:                ['coffee:coffee-script/register']

      # Targets

      project:                    # Run the project's tests
        src:                      ['<%= tstFiles %>']


    # grunt-codo: CoffeeScript API documentation generator
    codo:
      options:
        title:                    'screeps-statsd'
        debug:                    false
        inputs:                   ['<%= srcDir %>']
        output:                   '<%= docDir %>'


    # grunt-contrib-coffee: Compile CoffeeScript into native JavaScript
    coffee:

      # Targets

      build:                      # Compile CoffeeScript into target build directory
        expand:                   true
        ext:                      '.js'
        src:                      '<%= srcFiles %>'
        dest:                     '<%= libDir %>'


    # grunt-contrib-uglify: Compress and mangle JavaScript files
    uglify:

      # Targets

      build:
        files: [
          expand:                 true
          src:                    '<%= srcDir %>**/*.js'
        ]


    # grunt-contrib-clean: Clean the target files & folders, deleting anything inside
    clean:

      # Targets

      build:                      ['<%= srcDir %>**/*.js', 'index.js']        # Clean the build products
      docs:                       ['<%= docDir %>']


  ###############################################################################

  ### CUSTOM FUNCTIONS ###


  ### GRUNT MODULES ###

  # Loads all grunt tasks from devDependencies starting with "grunt-"
  require( 'load-grunt-tasks' )( grunt )

  ### GRUNT TASKS ###

  define 'lint',                  ['coffeelint']
  define 'test',                  ['mochacli']
  define 'docs',                  ['codo']
  define 'build:dev',             ['clean:build', 'lint', 'test', 'coffee:build']
  define 'build',                 ['build:dev', 'uglify:build']
  define 'default',               ['build']

  ###############################################################################
  grunt.initConfig config
