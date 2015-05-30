module.exports = (grunt) ->
  grunt.initConfig
    coffeelint: 
      app: ['app/**/*.coffee', 'api/**/*.coffee']

    simplemocha: 
      all: 
        src: ['test/**/*.coffee']

    watch: 
      scripts: 
        files: ['api/**/*.coffee']
        tasks: ['coffeelint', '']

  grunt.loadNpmTasks 'grunt-simple-mocha'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-watch'
