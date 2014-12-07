module.exports = (grunt) ->
  # load all grunt tasks matching the `grunt-*` pattern
  require('load-grunt-tasks')(grunt)

  grunt.initConfig
    watch:
      options:
        livereload: true
      coffeeify:
        files: 'app/coffee/*.coffee'
        tasks: ['coffeeify:dev']
        options:
          spawn: false
      sass:
        files: 'app/scss/*.scss'
        tasks: ['sass:dev']
        options:
          spawn: false
      haml:
        files: 'app/haml/index.haml'
        tasks: ['haml:dev']
        options:
          spawn: false

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

    bower_concat:
      main:
        dest: "dev/js/_bower.js"
        cssDest: "dev/css/_bower.css"
        mainFiles:
          rainbow: ['js/rainbow.js', 'js/language/css.js']

    connect:
      server:
        options:
          port: 9001
          base: 'dev'
          livereload: true
          open: true

    copy:
      dev:
        files: [
          {expand: true, flatten: true, src: ['app/resources/*'], dest: 'dev/resources', filter: 'isFile'}
        ]

    shell:
      test:
        command: './node_modules/karma/bin/karma start'

  grunt.registerTask 'compile', 'Compile all the assets', (type = 'dev') ->
    grunt.task.run [
      "coffeeify:#{type}"
      "sass:#{type}"
      "haml:#{type}"
    ]

  grunt.registerTask 'serve', [
    'clean:dev'
    'compile'
    'bower_concat'
    'copy'
    'connect'
    'watch'
  ]

  grunt.registerTask 'build', ->
    console.log "Not implemented yet"

  grunt.registerTask 'test', [
    'shell:test'
  ]

  grunt.registerTask 'default', ['serve']
