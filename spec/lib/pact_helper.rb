require 'pact'
require 'pact/provider/rspec'
require 'pact/xml'
require './spec/service_consumers/provider_states_for_quote_front_end_app'

Pact.configure do | config |
    config.diff_formatter = :embedded
end

Pact.service_provider "Calculator Service" do
  honours_pact_with "Quote Front End app" do
    pact_uri "/Users/hansdushanthakumar/Workspace/taigirFrontEndAppSOAP/spec/pacts/quote_front_end_app-calculator_service.json"
  end
end
