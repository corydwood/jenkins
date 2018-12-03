# Release Notes

## What is New in Jenkins 1.0.2.240

November 30, 2018

- Added `Get-JenkinsJobBuild` function for getting details of a build for a
  Jenkins job, such as the status.
- Added `Get-JenkinsJobBuildOutput` function for getting the output for a
  build for a Jenkins job.
- Added `Get-JenkinsQueueItem` function for  getting the details of a Jenkins
  item in the queue.
- Updated `Invoke-JenkinsJob` function to use `Command` instead of `RestCommand`
  for the `Type` parameter so `Invoke-WebRequest` is used instead of
  `Invoke-RestMethod`. This is needed to return the `Headers` property that
  contains the item that gets created in the queue in order to query it using the
  `Get-JenkinsQueueItem` function.

November 14, 2018

- Added `Disable-JenkinsJob` and `Enable-JenkinsJob` functions for disabling
  and enabling Jenkins jobs, respectively.
- Split unit tests into individual files and moved to `unit` subfolder.
- Converted `Resolve-JenkinsCommandUri` to be private function.
- Updated markdown documentation.
- Added Travis CI build pipeline for multi-platform builds/testing.

## What is New in Jenkins 1.0.1.222

August 4, 2018

- Jenkins 2.107.1 returns XML 1.1, which .NET can not parse. `Get-JenkinsJob`
  changes the version in the XML declaration to be "version=1.0" before
  returning it.
- Fixed: `Get-JenkinsObject` fails if using a forward slash "/" as the
  folder seperator.
- Added `Folder` parameter to `Rename-JenkinsJob`. It can now rename jobs
  in folders.
- Clean up markdown in readme.md.
- Split functions into separate files in the `lib` folder.
- Refactored module structure to improve deployability.
- Moved documentation into docs folder.
