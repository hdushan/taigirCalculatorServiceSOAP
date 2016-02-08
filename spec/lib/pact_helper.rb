require 'pact/consumer/rspec'

Pact.service_consumer "Quote Front End app" do
  has_pact_with "Calculator Service" do
    mock_service :calculator_service do
      port 9000
    end
  end
end