class Spinach::Features::Signup < Spinach::FeatureSteps
  include CommonSteps::Signup
  end
class Spinach::Features::Login < Spinach::FeatureSteps
    include CommonSteps::Login
  end
class Spinach::Features::AddAccountInformation < Spinach::FeatureSteps
      include FeatureSteps::AddAccountInformation
  end
