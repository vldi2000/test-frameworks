Spinach is a high-level BDD framework that leverages the expressive
[Gherkin language] to help you define
executable specifications of your application or library's acceptance criteria.
It is a tool to write human-readable tests that are mapped into code.

Conceived as an alternative to Cucumber, here are some of its design goals:

* Step maintainability: since features map to their own classes, their steps are
  just methods of that class. This encourages step encapsulation.

* Step reusability: In case you want to reuse steps across features, you can
  always wrap those in plain Ruby modules.

To set up a development environment do:

```shell
git clone https://github.com/rbenv/rbenv.git ~/.rbenv

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc

echo 'eval "$(rbenv init -)"' >> ~/.bashrc

source ~/.bashrc

type rbenv

Your terminal window should output the following:

Output
rbenv is a function
rbenv () 
{ 
    local command;
    command="$1";
    if [ "$#" -gt 0 ]; then
        shift;
    fi;
    case "$command" in 
        rehash | shell)
            eval "$(rbenv "sh-$command" "$@")"
        ;;
        *)
            command rbenv "$command" "$@"
        ;;
    esac
}

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

rbenv install -l

rbenv install 2.3.3

Output
-> https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.3.tar.bz2
Installing ruby-2.3.3...
Installed ruby-2.3.3 to /home/sammy/.rbenv/versions/2.3.3
rbenv global 2.3.3

Verify that everything is all ready to go by using the ruby command to check the version number:
ruby -v

Output
ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-linux]

sudo apt-get install gcc ruby ruby-dev libxml2 libxml2-dev  libxslt1-dev

bundle install

spinach -h  # help

spinach -r console # to run a feature

spinach -r console -t @integration # to run a set of features

rake BROWSER=chrome # to run as a rake task with parameters
```

```cucumber
Test Scenario:
@integration
Feature:  Login
    Scenario: I can login to 
	  Given I am on  login page
	  When I type valid email and password
    Then I can succesfully login to 
```

```cucumber
Test output should be:
Feature:  Login

  Scenario: I can login to 
    ✔  Given I am on  login page         
    ✔  When I type valid email and password      
    ✔  Then I can succesfully login to      

Steps Summary: (3) Successful, (0) Pending, (0) Undefined, (0) Failed, (0) Error
```
Write your first feature:

```cucumber
Feature: Test how spinach works
  In order to know what the heck is spinach
  As a developer
  I want it to behave in an expected way

  Scenario: Formal greeting
    Given I have an empty array
    And I append my first name and my last name to it
    When I pass it to my super-duper method
    Then the output should contain a formal greeting

  Scenario: Informal greeting
    Given I have an empty array
    And I append only my first name to it
    When I pass it to my super-duper method
    Then the output should contain a casual greeting
```

Now for the steps file. Remember that in Spinach steps are just Ruby classes,
following a camel-case naming convention. Spinach generator will do some
scaffolding for you:

```shell
$ spinach --generate
```

Spinach will detect your features and generate the following class

Then, you can fill it in with your logic - remember, it's just a class, you can
use private methods, mix in modules.

Then run your feature again running `spinach` and watch it all turn green! :)

## Shared Steps

You'll often find that some steps need to be used in many
features. In this case, it makes sense to put these steps in reusable
modules. For example, let's say you need a step that logs the
user into the site.

This is one way to make that reusable:

```ruby
# ... features/steps/common_steps/login.rb
module CommonSteps
  module Login
    include Spinach::DSL

    step 'I am logged in' do
      # log in stuff...
    end
  end
end
```

Using the module (in any feature):

```ruby
# ... features/steps/buying_a_widget.rb
class Spinach::Features::BuyAWidget < Spinach::FeatureSteps
  # simply include this module and you are good to go
  include CommonSteps::Login
end
```

## Audit

Over time, the definitions of your features will change. When you add, remove
or change steps in the feature files, you can easily audit your existing step
files with:

```shell
$ spinach --audit
```

This will find any new steps and print out boilerplate for them, and alert you
to the filename and line number of any unused steps in your step files.

This does not modify the step files, so you will need to paste the boilerplate
into the appropriate places. If a new feature file is detected, you will be
asked to run `spinach --generate` beforehand.

**Important**: If auditing individual files, common steps (as above) may be
reported as unused when they are actually used in a feature file that is not
currently being audited. To avoid this, run the audit with no arguments to
audit all step files simultaneously.


## Tags

Feature and Scenarios can be marked with tags in the form: `@tag`. Tags can be
used for different purposes:

- applying some actions using hooks (eg: `@javascript`, `@transaction`, `@vcr`)

```ruby
# When using Capybara, you can switch the driver to use another one with
# javascript capabilities (Selenium, Poltergeist, capybara-webkit, ...)
#
# Spinach already integrates with Capybara if you add
# `require spinach/capybara` in `features/support/env.rb`.
#
# This example is extracted from this integration.
Spinach.hooks.on_tag("javascript") do
  ::Capybara.current_driver = ::Capybara.javascript_driver
end
```

- filtering (eg: `@module-a`, `@customer`, `@admin`, `@bug-12`, `@feat-1`)

```cucumber
# Given a feature file with this content

@feat-1
Feature: So something great

  Scenario: Make it possible

  @bug-12
  Scenario: Ensure no regression on this
```

  Then you can run all Scenarios in your suite related to `@feat-1` using:

```shell
$ spinach --tags @feat-1
```

  Or only Scenarios related to `@feat-1` and `@bug-12` using:

```shell
$ spinach --tags @feat-1,@bug-12
```

  Or only Scenarios related to `@feat-1` excluding `@bug-12` using:

```shell
$ spinach --tags @feat-1,~@bug-12
```

By default Spinach will ignore Scenarios marked with the tag `@wip` or whose
Feature is marked with the tag `@wip`. Those are meant to be work in progress,
scenarios that are pending while you work on them. To explicitly run those, use
the `--tags` option:

```shell
$ spinach --tags @wip
```
## Reporters

Spinach supports two kinds of reporters by default: `stdout` and `progress`.
You can specify them when calling the `spinach` binary:

    spinach --reporter progress

When no reporter is specified, `stdout` will be used by default.

Other reporters:

* For a console reporter with no colors, try [spinach-console-reporter][spinach-console-reporter] (to be used with Jenkins)
* For a rerun reporter, try [spinach-rerun-reporter][spinach-rerun-reporter] (writes failed scenarios in a file)

Spinach will be used with Capybara Web Automation Framework

Capybara helps you test web applications by simulating how a real user would
interact with your app. It is agnostic about the driver running your tests and
comes with Rack::Test and Selenium support built in. WebKit is supported
through an external gem.

- **Intuitive API** which mimics the language an actual user would use.
- **Switch the backend** your tests run against from fast headless mode
  to an actual browser with no changes to your tests.
- **Powerful synchronization** features mean you never have to manually wait
  for asynchronous processes to complete.

  ```ruby
  =Navigating=
      visit('/projects')
      visit(post_comments_path(post))

  =Clicking links and buttons=
      click_link('id-of-link')
      click_link('Link Text')
      click_button('Save')
      click('Link Text') # Click either a link or a button
      click('Button Value')

  =Interacting with forms=
      fill_in('First Name', :with => 'John')
      fill_in('Password', :with => 'Seekrit')
      fill_in('Description', :with => 'Really Long Text…')
      choose('A Radio Button')
      check('A Checkbox')
      uncheck('A Checkbox')
      attach_file('Image', '/path/to/image.jpg')
      select('Option', :from => 'Select Box')

  =scoping=
      within("//li[@id='employee']") do
        fill_in 'Name', :with => 'Jimmy'
      end
      within(:css, "li#employee") do
        fill_in 'Name', :with => 'Jimmy'
      end
      within_fieldset('Employee') do
        fill_in 'Name', :with => 'Jimmy'
      end
      within_table('Employee') do
        fill_in 'Name', :with => 'Jimmy'
      end

  =Querying=
      page.has_xpath?('//table/tr')
      page.has_css?('table tr.foo')
      page.has_content?('foo')
      page.should have_xpath('//table/tr')
      page.should have_css('div .rg-lib-rg_player-errors-error.error')
      page.should have_content('foo')
      page.should have_no_content('foo')
      find_field('First Name').value
      find_link('Hello').visible?
      find_button('Send').click
      find('//table/tr').click
      find('//table/tr').set
      locate("//*[@id='overlay'").find("//h1").click
      all('a').each { |a| a[:href] }

  =Scripting=
      result = page.evaluate_script('4 + 4');

  =Debugging=
      save_and_open_page
  	 page.save_screenshot( 'shot.png' )
  	 page.document.synchronize( 10 ) do
  	   result = page.evaluate_script %($(':contains("Post")').length)
  	   raise Capybara::ElementNotFound unless result > 0
  	 end

  =Asynchronous JavaScript=
      click_link('foo')
      click_link('bar')
      page.should have_content('baz')
      page.should_not have_xpath('//a')
      page.should have_no_xpath('//a')

  =XPath and CSS=
      within(:css, 'ul li') { ... }
      find(:css, 'ul li').text
      locate(:css, 'input#name').value
      Capybara.default_selector = :css
      within('ul li') { ... }
      find('ul li').text
      locate('input#name').value
  	 ```
