# helpers
A collection of helpers for iobio.

## refresh_script.sh
A script to refresh urls within oncogene.iobio config files. For manual use, simply place the script within the directory where your config files live, and run. For automation or advanced use, set the `userPath` variable within the script to the directory of your choice.

Notes:
  * Configuration files must end with `.json` to be picked up by the script
    * `package.json` will not be picked up by the script
  * This file defaults to creating presigned URLs that expire after a week, though this variable can easily be changed by editing the `expireTime` variable.
  * AWS-CLI and credentials must be correctly set up for each bucket corresponding to the existing URLs
