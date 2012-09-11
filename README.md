command-on-change
=================

Watch folders with Node script, run command on save

`fs.watch` and `fs.watchFile` on each file/directory appears to be pretty expensive.
Looking for a better method 


Config file
===========

Create a config file name "config.json" with an associative array.
The keys are the folders to watch, the values are again an associative array with
keys: "command" which is the path of the script to be ran and "skip" which is an array
of directories/files to skip


Example
=======
```
  {
        "../project1/app"   : {
            "command"   : "../project1/sync.sh",
            "skip"      : []
        },
        "../../cms/"          : {
            "command"   : "../../commandonsave.sh",
            "skip"      : [
                "../../cms/css",
                "../../cms/js",
                "../../cms/data"
            ]
        }
    }
```

