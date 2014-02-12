module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-compass');

  grunt.initConfig
    watch:
      coffee:
        files: '_coffee/*.coffee'
        tasks: ['coffee:compileJoined']
      compass:
        files: '_scss/main.scss'
        tasks: ['compass:dist']

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

  grunt.registerTask 'default', ['watch']