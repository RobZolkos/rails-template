# Generic Rails Template to bootstrap a new rails app
#
# create a new rails app with :  rails new -m apptemplate appname
#
# created by Rob Zolkos

# add gems for all environments
gem 'haml-rails'
gem 'carrierwave'
gem 'fancybox-rails'
gem 'mysql2'
gem 'devise'
gem 'cancan'
gem 'redcarpet'
gem 'simple_form'
gem 'will_paginate'
gem 'twitter-bootstrap-rails'
gem 'bootstrap-will_paginate'

# add gems for production environment
gem 'unicorn',            :group => :production

# add gems for development, test environments
gem 'rspec-rails',        :group => [:development, :test]
gem 'factory_girl_rails', :group => [:development, :test]
gem 'capybara',           :group => [:development, :test]
gem 'launchy',            :group => [:development, :test]

# add gems for development environment
gem 'capistrano',         :group => :development
gem 'capistrano_colors',  :group => :development

# add gems for test environment
gem 'email_spec',         :group => :test
gem 'database_cleaner',   :group => :test
gem 'cucumber-rails',     :group => :test, :require => false
gem 'simplecov',          :group => :test, :require => false

# cp database example file
run 'cp config/database.yml config/database_example.yml'
run "echo 'config/database.yml' >> .gitignore"
run "echo 'public/assets' >> .gitignore"
run "echo 'public/uploads' >> .gitignore"
run "echo 'public/system' >> .gitignore"

# bundle and create git repo
run 'bundle install'
git :init
git :add => '.'
git :commit => "-aqm 'Initial Commit'"

# install testing frameworks
generate 'rspec:install'
generate 'cucumber:install'
generate 'email_spec:steps'
run 'rm -rf test'
inject_into_file 'config/application.rb', :after => "Rails::Application\n" do <<-RUBY
  config.generators do |g|
    g.view_specs false
    g.helper_specs false
    g.helper false
  end
RUBY
end

git :add => '.'
git :commit => "-aqm 'Install testing frameworks'"

# add folder and config for tests without rails
run 'mkdir spec_no_rails'
run "mkdir app/#{app_name}"
run "echo '-I app/#{app_name}/' >> .rspec"
git :add => '.'
git :commit => "-aqm 'Config for tests with no rails'"

# install twitter bootstrap and simpleform
generate 'simple_form:install --bootstrap'
generate 'bootstrap:install'
git :add => '.'
git :commit => "-aqm 'Install twitter bootstrap and simple_form'"

# install authentication and authorization
generate 'devise:install'
generate 'cancan:ability'

inject_into_file "app/controllers/application_controller.rb", :before => "\nend" do
  "\n\n  rescue_from CanCan::AccessDenied do |exception|\n    redirect_to root_url\n  end\n\n"
end

git :add => '.'
git :commit => "-aqm 'Install devise and cancan'"

# generate capistrano deploy script
run 'capify .'
git :add => '.'
git :commit => "-aqm 'Install deploy script'"

# clean up boilerplate rails code
run 'rm public/index.html'
run "rm app/assets/images/rails.png"
run "rm app/views/layouts/application.html.erb"
git :add => '.'
git :commit => "-aqm 'Clean up boiler plate code'"

# generate default site controller
generate(:controller, 'site index')
run "rm app/assets/stylesheets/site.css.scss"

create_file "app/assets/stylesheets/site.css.scss" do 
<<-'CSS'
body { padding-top:70px; }
CSS
end

create_file "app/views/layouts/application.html.haml" do 
<<-'HAML'
!!!
%html
  %head
    %title AppName
    = stylesheet_link_tag "application"
    = javascript_include_tag "application"
  %body
    .navbar.navbar-fixed-top
      .navbar-inner
        .container
          = link_to "AppName", root_path, :class=>"brand"
          %ul.nav
            %li= link_to "Home", root_path
    .container
      - if notice
        .alert.alert-info= notice
      - if alert
        .alert.alert-error= alert

      = yield
HAML
end
git :add => '.'
git :commit => "-aqm 'Create default site controller'"

# add devise required mailer code into environments
inject_into_file "config/environments/test.rb", :before => "\nend" do
  "\n\n   config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n\n"
end
inject_into_file "config/environments/development.rb", :before => "\nend" do
  "\n\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n\n"
end
inject_into_file "config/environments/production.rb", :before => "\nend" do
  "\n\n  config.action_mailer.default_url_options = { :host => 'production.com.au' }\n\n"
end
git :add => '.'
git :commit => "-aqm 'Add default action mailer url to environment files'"

gsub_file 'config/routes.rb', /get \"site\/index\"/, 'root :to => "site#index"'
git :add => '.'
git :commit => "-aqm 'Make site#index the root path'"

run 'bundle exec rake db:migrate'
git :add => '.'
git :commit => "-aqm 'Migrate database'"

# TO-DO
# copy over nginx and unicorn files
# copy over log rotate files
