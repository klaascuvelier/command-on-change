#!/usr/bin/env node

var fs      = require('fs'),
    exec    = require('child_process').exec,
    config  = {},
    base    = process.env.PWD + '/'

    ;


readConfigFile(function () {
    startObserving();
});



/**
 * Read the config file and get started!
 *
 * @param function callback
 */
function readConfigFile(callback) {
    fs.readFile('./config.json', 'utf8', function (err, data) {
        try {
            config = JSON.parse(data);

            if (callback) {
                callback();
            }
        }
        catch (e) {
            console.log(e);
            console.error('Could not load config file');
        }
    });
}


/**
 * Start observing all specified folders for changes
 */
function startObserving() {
    var index       = void 0,
        onChange    = function () {
            console.log('CHANGED');
        };

    for (index in config) {
        if (config.hasOwnProperty(index)) {
            // console.log(base + index, config[index]);
            try {
                watchDirectoryRecursively(base + index, (function(script) {
                    return function () {
                        try {
                            exec(script, function (error, stdout, stderr) {

                                if (error) {
                                    console.log('CHILD PROCESS ERROR', script, error);
                                }
                                else if (stderr) {
                                    console.log('CHILD PROCESS STD ERROR', script, stderr);
                                }
                                else {
                                    console.log('CHILD PROCESS', script, stdout);
                                }
                            });
                        }
                        catch (e) {
                            console.log('COULD NOT RUN SCRIPT', script, e);
                        }
                    };
                })(config[index]['command']), config[index]['skip']);
            }
            catch (e) {
                console.log('FAILED TO WATCH DIRECTORY', index, e);
            }
        }
    }
}



/**
 * Watch directory/files and content recursively for changes
 *
 * @param String directory path to observe
 * @param function callback
 * @param Array skip
 */
function watchDirectoryRecursively(directory, callback, skip) {

    fs.readdir(directory, function (error, files) {
        files.forEach(function (file) {

            // skip fricking dotfiles, except for .htaccess
            if (file.substr(0, 1) !== '.' && file !== '.htaccess')
            {
                var fullPath = directory + '/' + file;

                // don't observe files/folders in the skip array
                if (!!skip && skip.map(function (item) { return base + item; }).indexOf(fullPath) > -1) {
                    return;
                }


                fs.stat(fullPath, function (error, info) {
                    
                    if (!error) {
                        // if is directory, also scan directory for files
                        if (info.isDirectory()) {
                            watchDirectoryRecursively(fullPath, callback, skip);
                        }
                       
                        fs.unwatchFile(fullPath);
                        fs.watchFile(fullPath, {
                            persistent  : true,
                            interval    : 5000
                        }, (function (fullPath) {
                            return function (curr, prev) {

                                fs.stat(fullPath, function (error, info) {

                                    if (!error) {
                                        // if is directory, unwatch and rewatch all files
                                        if (info.isDirectory()) {
                                            console.log('REWATCH ', fullPath);
                                            watchDirectoryRecursively(fullPath, callback, skip);
                                        }
                                       
                                        if (callback) {
                                            callback();
                                        }
                                        else {
                                            console.log('CHANGE DETECTED, BUT NO CALLBACK');
                                        }
                                    }
                                    else {
                                        try {
                                            fs.unwatch(fullPath);
                                        }
                                        catch (e) {
                                            console.log('COULD NOT UNWATCH ', fullPath, e);
                                        }
                                    }

                                });

                            };
                        })(fullPath));
                        
                    }

                });
            }
        });
    });
}


/**
 * Send message to notification center
 *
 * @param String message
 */
function notify(message) {
    console.log(message);
}