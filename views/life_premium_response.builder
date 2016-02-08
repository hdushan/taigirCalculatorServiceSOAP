xml.SOAP(:Envelope, "xmlns:SOAP" => "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:calculator" => "http://www.hans.com/calculator") do
  xml.SOAP :Body do
    xml.calculator :LifePremiumResponse do
      xml.calculator(:LifePremium, message)
    end
  end
end
