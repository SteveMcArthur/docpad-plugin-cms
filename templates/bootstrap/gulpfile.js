/*global require*/
var gulp = require('gulp');
var concat = require('gulp-concat');
//var uglify = require('gulp-uglify');

var DEST = './src/static/cmsplus/js/';

var srcFiles = 
	[
		"./src/static/cmsplus/js/fastclick.js",
		"./src/static/cmsplus/js/nprogress.js",
		"./src/static/cmsplus/js/bootstrap-progressbar.js",
		"./src/static/cmsplus/js/icheck.min.js",
		"./src/static/cmsplus/js/moment.min.js",
		"./src/static/cmsplus/js/daterangepicker.js"
	];

gulp.task('scripts', function() {
    return gulp.src(srcFiles)
      .pipe(concat('base.js'))
      .pipe(gulp.dest(DEST));
});

gulp.task('default', ['scripts']);
