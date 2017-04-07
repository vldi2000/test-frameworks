# -*- encoding : utf-8 -*-
class Test < Spinach::FeatureSteps
    include Spinach::DSL
    step 'I type valid new user info' do
      find('[name="first"]').set Faker::Name.unique.first_name
      find('[name="last"]').set Faker::Name.unique.last_name
      find('[name="company"]').set Faker::Company.unique.name
      find('[name="email"]').set Faker::Internet.email
       open('data.out', 'w') { |f|
        f.puts find('[name="email"]').value
        }
      find('[name="password"]').set find('[name="email"]').value
      click_button('Sign Up')
      visit '/account'
    end
    step 'I am on plethora login page' do
      visit '/log-out'
      visit '/log-in'
    end
    step 'I type valid shipping address information' do
      find('[name="name"]').set Faker::Name.unique.name
      find('[name="coname"]').set Faker::Company.unique.name
      find('[name="street"]').set Faker::Address.unique.street_address
      find('#addressForm > input:nth-of-type(2)').set Faker::Address.secondary_address
      find('[name="city"]').set Faker::Address.city
      find('[name="state"]').set Faker::Address.state
      find('[name="zip"]').set '12345'
      find('[name="phone"]').set Faker::PhoneNumber.phone_number
    end
  end
