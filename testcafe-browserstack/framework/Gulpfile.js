var path        = require('path');
var gulp        = require('gulp');
var babel       = require('gulp-babel');
var mocha       = require('gulp-mocha');
var sequence    = require('gulp-sequence');
var del         = require('del');
var nodeVersion = require('node-version');
var execa       = require('execa');

var PACKAGE_PARENT_DIR  = path.join(__dirname, '../');
var PACKAGE_SEARCH_PATH = (process.env.NODE_PATH ? process.env.NODE_PATH + path.delimiter : '') + PACKAGE_PARENT_DIR;


gulp.task('test-testcafe', function () {
    if (!process.env.BROWSERSTACK_USERNAME || !process.env.BROWSERSTACK_ACCESS_KEY)
        throw new Error('Specify your credentials by using the BROWSERSTACK_USERNAME and BROWSERSTACK_ACCESS_KEY environment variables to authenticate to BrowserStack.');

    var testCafeCmd = path.join(__dirname, 'node_modules/.bin/testcafe');

    var testCafeOpts = [
        'browserstack:chrome',
        'tests/**/*.js',
        '-s', '.screenshots'
    ];

    // NOTE: we must add the parent of plugin directory to NODE_PATH, otherwise testcafe will not be able
    // to find the plugin. So this function starts testcafe with proper NODE_PATH.
    process.env.NODE_PATH = PACKAGE_SEARCH_PATH;

    var child = execa(testCafeCmd, testCafeOpts);

    child.stdout.pipe(process.stdout);
    child.stderr.pipe(process.stderr);

    return child;
});

gulp.task('test', sequence('test-testcafe'));
