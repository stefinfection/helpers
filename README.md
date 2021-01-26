# helpers
A collection of helpers for iobio.

## refresh_script.sh
A script to refresh urls within oncogene.iobio config files. Place the configuration files that you'd like to be updated in a directory with this script, then run 
`sh refresh_script.sh` manually, or add it to your cron jobs.

Notes:
  * Configuration files must end with `.json` to be picked up by the script
  * This file defaults to creating presigned URLs that expire after a week, though this variable can easily be changed
  * AWS-CLI and credentials must be correctly set up for each bucket corresponding to the existing URLs
