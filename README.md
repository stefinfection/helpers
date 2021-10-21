# helpers
A collection of helpers for iobio.

## refresh_script.sh
A script to refresh urls within oncogene.iobio config files. For manual use, simply place the script within the directory where your config files live, and run. For automation or advanced use, set the `userPath` variable within the script to the directory of your choice.

Notes:
  * Dependencies: [jq](https://stedolan.github.io/jq/) and [aws-cli](https://aws.amazon.com/cli/) with iobio credentials
  * Configuration files must end with `.json` to be picked up by the script
    * `package.json` will not be picked up by the script
  * Defaults to creating presigned URLs that expire after a week, though this variable can easily be changed by editing the `expireTime` variable.


## galaxy_refresh.sh
A script to refresh urls within the galaxy-specific oncogene config files. For manual use, simply place the script within the directory where your config files live, and run. For automation or advanced use, set the `userPath` and `fileName` variables within the script to the directory and file of your choice.

Notes:
  * Dependencies: [jq](https://stedolan.github.io/jq/) and [aws-cli](https://aws.amazon.com/cli/) with iobio credentials
  * Defaults to creating presigned URLs that expire after a week, though this variable can easily be changed by editing the `expireTime` variable.
