var gulp = require('gulp');
var gutil = require('gulp-util');
var source = require('vinyl-source-stream');
var rename = require('gulp-rename');
var buffer = require('vinyl-buffer');
var watchify = require('watchify');
var browserify = require('browserify');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');

gulp.task('watch', function() {
  var b = browserify({
    entries: ['./src/sosowgw.js'],
    debug: true
  });
  var bundler = watchify(b);
  bundler.on('update', rebundle);

  function rebundle() {
    return bundler.bundle()
      // log errors if they happen
      .on('error', gutil.log.bind(gutil, 'Browserify Error'))
      .pipe(source('sosowgw.js'))
      .pipe(buffer())
      // .pipe(sourcemaps.init({ loadMaps: true }))
      .pipe(gulp.dest('./dist'))
      .pipe(gulp.dest('./'))
      .pipe(uglify())
      .pipe(rename({ extname: '.min.js' }))
      // .pipe(sourcemaps.write('./'))
      .pipe(gulp.dest('./dist'))
      .pipe(gulp.dest('./'))
      ;
  }

  return rebundle();
});

gulp.task('default', ['watch']);