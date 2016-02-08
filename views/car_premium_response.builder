xml.SOAP(:Envelope, "xmlns:SOAP" => "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:calculator" => "http://www.hans.com/calculator") do
  xml.SOAP :Body do
    xml.calculator :CarPremiumResponse do
      xml.calculator(:CarPremium, message)
    end
  end
end
