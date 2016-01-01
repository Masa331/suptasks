module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    cssmin: {
      suptasks: {
        src: 'public/css/suptasks.css',
        dest: 'public/css/suptasks.min.css'
      },
      fontAwesome: {
        src: 'public/css/font-awesome.css',
        dest: 'public/css/font-awesome.min.css'
      }
    },

    concat: {
      options: {
        separator: ';'
      },
      css: {
        src: ['public/css/bootstrap.min.css', 'public/css/suptasks.min.css', 'public/css/font-awesome.min.css'],
        dest: 'public/css/styles.min.css'
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-cssmin');

  // Default task(s).
  grunt.registerTask('default', ['cssmin', 'concat']);
};
