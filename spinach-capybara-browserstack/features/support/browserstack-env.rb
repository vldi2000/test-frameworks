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
require 'yaml'
require 'browserstack/local'

# monkey patch to avoid reset sessions
class Capybara::Selenium::Driver < Capybara::Driver::Base
  def reset!
    if @browser
      @browser.navigate.to('about:blank')
    end
  end
end

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'single'

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "../../config/#{CONFIG_NAME}.config.yml")))
CONFIG['user'] = ENV['BROWSERSTACK_USERNAME'] || CONFIG['user']
CONFIG['key'] = ENV['BROWSERSTACK_ACCESS_KEY'] || CONFIG['key']

Spinach::FeatureSteps.send(:include, Spinach::FeatureSteps::Capybara)

Capybara.register_driver :browserstack do |app|
@caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])

# Code to start browserstack local before start of test
if @caps['browserstack.local'] && @caps['browserstack.local'].to_s == 'true';
  @bs_local = BrowserStack::Local.new
  bs_local_args = {"key" => "#{CONFIG['key']}"}
  @bs_local.start(bs_local_args)
end

Capybara::Selenium::Driver.new(app,
  :browser => :remote,
  :url => "http://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",
  :desired_capabilities => @caps
)
end

Capybara.configure do |config|
config.default_driver          = :browserstack
config.current_driver          = :browserstack
config.javascript_driver       = :browserstack
config.default_selector        = :css
config.default_max_wait_time   = 3
config.app_host                = ''
config.match                   = :prefer_exact
config.ignore_hidden_elements  = false
Capybara.reset_sessions!
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

RSpec.configure do |config|
config.include Capybara::UserAgent::DSL
config.include Capybara::DSL
config.expect_with :rspec do |c|
  c.syntax = [:should, :expect]

# Code to stop browserstack local after end of test
at_exit do
@bs_local.stop unless @bs_local.nil?
  end
end
 end
end
