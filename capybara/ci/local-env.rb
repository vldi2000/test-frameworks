require 'spinach/capybara'
require 'rspec'
require 'capybara/rspec'
require 'pry'
require 'spinach-console-reporter'
require 'capybara/user_agent'
require 'selenium/webdriver'
require 'headless'
require 'rubygems'
require 'capybara/dsl'
require 'faker'
require 'spinach-rerun-reporter'
require 'browserstack-webdriver'
require 'open3'

Spinach::FeatureSteps.send(:include, Spinach::FeatureSteps::Capybara)
#[:chrome, :firefox].each do |browser|
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
#Capybara.register_driver :selenium do |app|
  #Capybara::Selenium::Driver.new(app,
    #browser: :firefox,
    #desired_capabilities: Selenium::WebDriver::Remote::Capabilities.firefox(marionette: false))
end

Capybara.configure do |config|
  config.default_driver          = :selenium
  config.current_driver          = :selenium
  config.javascript_driver       = :selenium
  config.default_selector        = :css
  config.default_max_wait_time   = 3
  config.app_host                = ''
  config.match                   = :prefer_exact
  config.ignore_hidden_elements  = false
  config.reset_sessions!
  Capybara.run_server = false
  Capybara.page.driver.browser.manage.window.maximize

  # capybara helpers
  # wait for ajax completed
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  # overwrite this method for your modal
  def modal_id
  end

  # wait for modal hidden
  def wait_for_modal_hidden
    wait_until { !page.find(modal_id).visible? }
  rescue Capybara::TimeoutError
    flunk 'Expected modal to be visible.'
  end

  # wait for modal visible
  def wait_for_modal_visible
    wait_until { page.find(modal_id).visible? }
  rescue Capybara::TimeoutError
    flunk 'Expected modal to be visible.'
  end

if ENV['BROWSER'] == 'chrome'
Capybara.configure do |config|
   config.default_driver          = :chrome
   config.current_driver          = :chrome
   config.javascript_driver       = :chrome
 end
end

if ENV['BROWSER'] == 'firefox'
Capybara.configure do |config|
   config.default_driver          = :firefox
   config.current_driver          = :firefox
   config.javascript_driver       = :firefox
 end
end

RSpec.configure do |config|
  config.include Capybara::UserAgent::DSL
  config.include Capybara::DSL
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
 end
end
