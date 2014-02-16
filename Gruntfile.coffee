module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-compass')
  grunt.loadNpmTasks('grunt-contrib-haml')

  grunt.initConfig
    watch:
      coffee:
        files: '_coffee/*.coffee'
        tasks: ['coffee:compileJoined']
      compass:
        files: '_scss/styles.scss'
        tasks: ['compass:dist']
      haml:
        files: '_haml/index.haml'
        tasks: ['haml:dist']

    coffee:
      compileJoined:
        options:
          join: true
          sourceMap: true
        files:
          'js/app.js': '_coffee/*.coffee'

    compass:
      dist:
        options:
          config: 'config.rb'
          sassDir: '_scss',
          cssDir: 'css',
          environment: 'production'

    haml:
      dist:
        files:
          'index.html': '_haml/index.haml'

  grunt.registerTask 'default', ['watch']