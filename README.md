# Ability.ge

## Summary
Ability.ge allows users to evaluate places on accessibilty standards. The evaluations can be simple (public evals are about 15 questions) or complex (expert evaluations have hundreds of questions with ability to include measurements).

Due to continous changes on what the venues, questions and all of the features and flags, an admin interface to manage the venues and questions was never built. Instead a simple CSV upload exists to load this data. 

### Venues
To upload venues and their categories, use `VenueCategory.process_csv_upload` in the [app/models/venue_category.rb file](/app/models/venue_category.rb). There are helper methods of `process_complete_csv_upload` to delete everything on record first (this includes all evaluations) and then upload the CSV data; and `update_csv_upload` that will load any new records or update existing records.

### Questions
To upload questions and their categories, `QuestionCategory.process_csv_upload` in the [app/models/question_category.rb file](/app/models/question_category.rb). There are helper methods of `process_complete_csv_upload` to delete everything on record first (this includes all evaluations) and then upload the CSV data; and `update_csv_upload` that will load any new records or update existing records.

### Summaries
There is a PlaceSummary model to record the summary of the evaluations for each place. There are 3 different types of summaries for each assessment type (public/expert):
* Overall - summary of all evaluations for this place and assessment type
* Disability - summary of all evaluations for this place and assessment type for a given disability
* Instance - summary of a particular evaluation

These summaries are updated automatically whenever a new evaluation is saved.

NOTE: For expert evaluations, the Disability summary only shows the latest evaluation summary - not a summary of all existing evaluations. This is because it was decided that a new expert evaluation should replace one that is already on file.


## Current GEM Versions
Look at the Gemfile for a complete list.
* Ruby 1.9.2-p290
* Rails 3.1.10
* Bootstrap 2.3
* Capistrano 2.12
* Devise 2.0.4
* Unicorn 4.2.1


## Requirements
* git
* Ruby 1.9.2
* [rvm](http://rvm.io/) - share gems between applications
* nginx - for staging/production server

Environment variables
You will need the following [Environment Variables](https://help.ubuntu.com/community/EnvironmentVariables) set. 
* APPLICATION_FROM_EMAIL - email address to send all emails from
* APPLICATION_FROM_PWD - password of above email address
* APPLICATION_ERROR_TO_EMAIL - email address to send application errors to
* ACCESSIBILITY_FACEBOOK_APP_ID - Facebook is one of the options for logging in to the system and you must have an app account created under facebook developers. This key is for use on production sites. This key stores the application id. (optional)
* ACCESSIBILITY_FACEBOOK_APP_SECRET - This key stores the facebook application secret for production sites. (optional)

After you add environment variables, do the following in order for your application to be able to see the values:
* on a dev machine - reboot your computer
* on a server:
    * in console type in 'source /etc/environment'
    * logout of the server and close all terminal windows
    * log back into server and stop/start nginx and unicorn


## Internationalization/Translations
The application comes ready to work with two language site translations: Georgian and English. You can add more languages by adding more locale translation files to the [/config/locales/](/config/locales/) folder. The template file at [/app/views/layouts/application.html.erb](/app/views/layouts/application.html.erb) is setup to show all available languages. Please read the [Rails I18n](http://guides.rubyonrails.org/i18n.html) for information on how to use translations throughout your application.

In order for the application to know which language to use for the site translations, the [/config/routes.rb](/config/routes.rb) file has been updated to force the locale of the language to be at the beginning of the URL. For instance, /en/admin/users instead of /admin/users. If the URL does not include a language locale, the default locale that is set in [/config/application.rb](/config/application.rb) will be used.  In the routes file, there is a 'scope ":locale"' statement. All routes statements that you enter by hand or that are created when you run rails g scaffold must be contained within this scope statement (all scaffold statements add routes to the top of the file so you will have to move them by hand). 


In addition to site translations, you may also need user provided content to be saved in multiple translations. This is where the [gem globalize](https://github.com/globalize/globalize/tree/3-1-stable) comes into play. In essence, this gem uses an additional table to record the translations. For example, if you have a pages table/Page model, then a page_translations table/PageTranslation model will contain all of the translated objects.



## Authentication
The application uses [Devise](https://github.com/plataformatec/devise/tree/v2.0) to manage authentication for the system. This app uses inerited roles so as long as someone has the equivalent role, or one that is higher, they have access.

The site has the following roles (weakest to strongest):
* user - Anyone can create an account and by default they get this role. This person can submit public evaluations.
* certification - This person has the ability to fill out expert evaluations.
* organization_admin - This person has the ability to assign existing users to their organization.
* site_admin - This person has access to most admin features: edit text, manage users, manage video guids, manage help text, etc.
* admin - This person can add other admins to the site.

## Omniauth (facebook) Login
Omniauth login allows users to login in with 3rd party systems like facebook or twitter. This application has facebook login built in by default.


## Deployment with Capistrano
[Capistrano](https://github.com/capistrano/capistrano/wiki) is used to deploy the application to a staging and production enviornment. 

The config file at [/config/deploy.rb](/config/deploy.rb) is the basic setup for capistrano deploying. The file is set up to:
* deploy to multiple environments, default is staging
* only keep the last 2 releases
* only compile and send the assets if the assets have changed

To setup the config files for the staging and production server, look in the [/config/deploy](/config/deploy) folder. The staging.rb and production.rb files contain the variables that are needed for deployment (server user name, server folder location, github project name, etc). 

Within the /config/deploy folder are folders for each server you can deploy to (staging and production) that contain more configuration.
* nginx.conf
    * update this file with the application and user variables you set in the staging.rb/production.rb file
    * server name - root url to site
    * timeout length - default is 30 seconds
* unicorn.rb
    * update this file with the application and user variables you set in the staging.rb/production.rb file
    * port number - each application on the server must have a unique port number, run 'netstat -anltp | grep "LISTEN"' to see which ports are being used
    * timeout length - default is 30 seconds
    * number of worker processes - default is 2
* unicorn_init.sh
    * update this file with the application and user variables you set in the staging.rb/production.rb file

The staging environment is set as the default so if you run 'cap deploy' the application will be deployed to the staging server. Use 'cap production deploy' to deploy to the production server.

## Helpful Additions/Tools

### Sending Emails
The application is setup to send email using Google SMTP. You can view/edit these settings at [/config/initializers/gmail.rb](/config/initializers/gmail.rb).

### Emails in Development Mode
[Mailcatcher](http://mailcatcher.me/) is a helpful gem in development mode for catching all emails that your application sends, whether they be error message emails, feedback emails, etc and showing them in a web interface instead of actually sending them to the intended users. Simply run mailcatcher at the command line and then go to [http://127.0.0.1:1080/](http://127.0.0.1:1080/) to see the emails that are sent. You will be able to see the html and text version of the emails.

### Exception Notifications
[Exception Notification](http://smartinez87.github.io/exception_notification/) is a gem that is wonderful at catching errors that occur in your application and sending you emails to let you know about it. You can customize the email settings (i.e., subject, to email, from email, etc) by going to [/config/environments](/config/environments) and updating the appropriate file.  Look at the bottom of the file to see the default settings that come in this application. You can customize what type of exceptions you want to be notified about by editing the code at the bottom of [/app/controllers/application_controller.rb](/app/controllers/application_controller.rb).

### Gon
[Gon](https://github.com/gazay/gon) is a gem that lets you set varaibles in your controllers and have them be accessible in javascript.

### jQuery DataTables
[DataTables](http://www.datatables.net/) turns a boring table of data into one that can be sorted, searched and paginated. The user admin page uses DataTables with ajax calls. The following files are used for this:
* [/app/datatables/user_datatable.rb](/app/datatables/user_datatable.rb) - this file defines the methods to create the sql to search, sort and paginate and then return the results in the desired format.
* [/app/controllers/admin/users_controller.rb](/app/controllers/admin/users_controller.rb) - the index action calls the user_datatable.rb file when called using json.
* [/app/views/admin/users/index.html.erb](/app/views/admin/users/index.html.erb) - this file contains the html table and the data-source attribute with the url to get the data via ajax
* [/app/assets/javscripts/search.js](/app/assets/javscripts/search.js) - this file assigns the DataTable object to the html table

To create your own datatables, simply copy and paste these files and tweak as necessary.

Also, the translation of the DataTable interface into Georgian is located at [/public/datatable_ka.txt](/public/datatable_ka.txt). If the page is in Georgian, this file path is set in a variable in [/app/controllers/application_controller.rb](/app/controllers/application_controller.rb) under the method initialize_gon.

### Unicorn
[Unicorn](http://unicorn.bogomips.org/) is a Rails server that this application is setup to use in staging and production environments.

### Maintenance Mode
The nginx config file located at [/config/deploy/staging/nginx.conf](/config/deploy/staging/nginx.conf) and [/config/deploy/production/nginx.conf](/config/deploy/production/nginx.conf) is setup to look for a file in the [/public](/public) folder called maintenance.html.  If this file is found, the file will automatically be shown instead of processing whatever request the user is asking for. 

In the /public folder, there is a file called [maintenance_disabled.html](/public/maintenance_disabled.html). This file is a plain html file that is setup to have a similar look as the [/app/views/layout/application.html.erb](/app/views/layout/application.html.erb). The content of this file is a simple message to the user indicating that the site is down and for how long. 

To turn on maintenance mode, either rename the file and deploy or simply rename the file on the server.

To turn off maintenance mode, either rename the file to anything other than maintenance.html and deploy or simply renmae the file on the server.


