require File.dirname(__FILE__) + '/spec_helper'

set :environment, :test
 
describe "QuickQuote Calculator Service" do
  include Rack::Test::Methods
 
  def app
    @app ||= CalculatorService.new
  end
 
  it "should respond to /" do
    get '/'
    expect(last_response).to be_ok
  end
  
  it "should respond to /calculator_service/wsdl" do
    get '/calculator_service/wsdl'
    expect(last_response).to be_ok
  end
end