path = require 'path'

allowCorsMiddleware = (req, res, next) ->
  res.setHeader 'Access-Control-Allow-Origin', '*'
  next()

module.exports = ->
  # Project configuration
  pkg = @file.readJSON 'package.json'

  @initConfig
    pkg: @file.readJSON 'package.json'

    # Schemas
    yaml:
      schemas:
        files: [
          expand: true
          cwd: 'schemata/'
          src: '*.yaml'
          dest: 'schema/'
        ]

    # Building for browser
    browserify:
      options:
        transform: [
          ['coffeeify', {global: true}]
        ]
        browserifyOptions:
          extensions: ['.coffee', '.js']
          ignoreMissing: true
          standalone: 'fbpspec'
      lib:
        files:
          'browser/fbp-spec.js': ['src/index.coffee']

    watch:
      src:
        files: [
          "src/**/*"
          "examples/**/*"
          "spec/**/*"
        ]
        tasks: "test"
        options:
          livereload: true

    exec:
      runtime:
        command: 'python2 protocol-examples/python/runtime.py --port 3334'

    # Web server for the browser tests
    connect:
      server:
        options:
          port: 8000
          livereload: true
          middleware: (connect, options, middlewares) ->
            middlewares.unshift allowCorsMiddleware
            return middlewares

    # Coding standards
    yamllint:
      schemas: ['schemata/*.yaml']
      examples: ['examples/*.yml']

    coffeelint:
      components: ['Gruntfile.coffee', 'spec/*.coffee']
      options:
        'max_line_length':
          'level': 'ignore'

    # Tests
    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'
          grep: process.env.TESTS

    # CoffeeScript compilation of tests
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: '*.coffee'
        dest: 'browser/spec'
        ext: '.js'

    downloadfile:
      files: [
        { url: 'http://noflojs.org/noflo-browser/everything.html', dest: 'spec/fixtures' }
        { url: 'http://noflojs.org/noflo-browser/everything.js', dest: 'spec/fixtures' }
      ]

    # BDD tests on browser
    mocha_phantomjs:
      all:
        options:
          output: 'test/result.xml'
          reporter: 'spec'
          urls: ['http://localhost:8000/spec/runner.html']

    # Deploying
    copy:
      ui:
        files: [ expand: true, cwd: './ui/', src: '*', dest: './browser/' ]

    'gh-pages':
      options:
        base: 'browser/',
        user:
          name: 'fbp-spec bot',
          email: 'jononor+fbpspecbot@gmail.com'
        silent: true
        repo: 'https://' + process.env.GH_TOKEN + '@github.com/flowbased/fbp-spec.git'
      src: '**/*'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-yaml'
  @loadNpmTasks 'grunt-browserify'
  @loadNpmTasks 'grunt-contrib-watch'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-yamllint'
  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-test'
  @loadNpmTasks 'grunt-contrib-connect'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-exec'
  @loadNpmTasks 'grunt-downloadfile'

  @registerTask 'examples:bundle', =>
    examples = require './examples'
    examples.bundle()

  # Grunt plugins used for deploying
  @loadNpmTasks 'grunt-contrib-copy'
  @loadNpmTasks 'grunt-gh-pages'


  # Our local tasks
  @registerTask 'build', 'Build', (target = 'all') =>
    @task.run 'yaml'
    @task.run 'browserify'
    @task.run 'examples:bundle'
    @task.run 'copy:ui'

  @registerTask 'test', 'Build and run tests', (target = 'all') =>
    @task.run 'coffeelint'
    @task.run 'yamllint'
    @task.run 'build'
    @task.run 'mochaTest'
    if target != 'nodejs'
      @task.run 'downloadfile'
      @task.run 'coffee:spec'
      @task.run 'connect'
      @task.run 'mocha_phantomjs'

  @registerTask 'default', ['test']

  @registerTask 'uidev', ['connect:server:keepalive']

  @registerTask 'dev', 'Developing', (target = 'all') =>
    @task.run 'test'
    @task.run 'watch'
