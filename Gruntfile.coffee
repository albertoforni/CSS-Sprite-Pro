module.exports = (grunt) ->
  # load all grunt tasks matching the `grunt-*` pattern
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    watch:
      coffeeify:
        files: 'app/coffee/*.coffee'
        tasks: ['coffeeify:dev']
      compass:
        files: 'app/scss/*.scss'
        tasks: ['sass:dev']
      haml:
        files: 'app/haml/index.haml'
        tasks: ['haml:dev']

    clean:
      dev: ['dev']

    coffeeify:
      dev:
        cwd:  'app/coffee'
        src:  ['app.coffee']
        dest: 'dev/js'

    sass:
      dev:
        options:
          style: 'expanded'
        files:
          'dev/css/style.css': 'app/scss/style.scss'

    haml:
      dev:
        files:
          'dev/index.html': 'app/haml/index.haml'

    connect:
      server:
        options:
          port: 9001
          base: 'dev'
          keepalive: true
          open: true

    concurrent:
      target:
        tasks: ['watch', 'connect']
        options:
          logConcurrentOutput: true

  grunt.registerTask 'serve', [
    'concurrent'
  ]

  grunt.registerTask 'default', ['serve']
