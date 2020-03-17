# S3 plugin for Redmine

## Description
This [Redmine](http://www.redmine.org) plugin makes file attachments be stored on [Amazon S3](http://aws.amazon.com/s3) rather than on the local filesystem. This is a fork of a [fork](http://github.com/ka8725/redmine_s3) for [original gem](http://github.com/tigrish/redmine_s3). It works with Redmine 3.0.0 and should work with 2.6.x versions.
Changes are:

1. Image thumbnail generation introduced. Image thumbnail is generated if it fails to display once page is opened (there is an AJAX call to server here). Folder for thumbnails is specified in config.
2. Files are now stored using relative paths with default redmine folder structure (`file_folder/year/month/file.ext`). It is based on “disk_directory” column of the database.
3. Now files have their original filenames included into “Content-Disposition” value of S3 object so that browser downloads files with original filenames without a digital prefix (e.g. image.jpg instead of 150319143442_image.jpg).
4. URLs for thumbnails and images use full URL to S3 without the 'go to redmine-server => redirect to S3' behavior. Other files are still served with redirect.
5. Fixed "View" (clicking the “Magnifier” icon to the right from the file name) action for text files and diffs.
6. `files_to_s3` task now sets correct “Content-Type” and “Content-Disposition” for files. The task searches correct directory in database before uploading files to S3.
7. `files_to_s3` file existence check was fixed and now uses folder from S3 config.
8. Max file size validation using redmine `attachment_max_size` config was added both for task and for new files.

## Installation
1. Make sure Redmine is installed and cd into it's root directory
2. `git clone git://github.com/redcloak/redmine_s3.git plugins/redmine_s3`
3. `cp plugins/redmine_s3/config/s3.yml.example config/s3.yml`
4. Edit config/s3.yml with your favourite editor
5. `bundle install --without development test` for installing this plugin dependencies (if you already did it, doing a `bundle install` again whould do no harm)
6. Restart mongrel/upload to production/whatever
7. *Optional*: Run `rake redmine_s3:files_to_s3` to upload files in your files folder to s3
8. `rm -Rf plugins/redmine_s3/.git`

## Options Overview
* The bucket specified in s3.yml will be created automatically when the plugin is loaded (this is generally when the server starts).
* *Deprecated* (no longer supported, specify endpoint option instead) If you have created a CNAME entry for your bucket set the cname_bucket option to true in s3.yml and your files will be served from that domain.
* After files are uploaded they are made public, unless private is set to true.
* Files can use private signed urls using the private option
* Private file urls can expire a set time after the links were generated using the expires option
* If you're using a Amazon S3 clone, then you can do the download relay by using the proxy option.
* Thumbnails for image files are stored at folder 'tmp' inside bucket (can be changed at s3.yml)

## Options Detail
* access_key_id: string key (required)
* secret_access_key: string key (required)
* bucket: string bucket name (required)
* folder: string folder name inside bucket (for example: 'attachments')
* endpoint: string endpoint instead of s3.amazonaws.com
* private: boolean true/false
* expires: integer number of seconds for private links to expire after being generated
* proxy: boolean true/false
* thumb_folder: string folder where attachment thumbnails are stored; defaults to 'tmp'
* region: aws s3 region string (e.g. 'eu-central-1')
* Defaults to private: false, proxy: false, default endpoint, and default expires


## License

This plugin is released under the [MIT License](http://www.opensource.org/licenses/MIT).
