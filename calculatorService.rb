require 'bundler'
Bundler.setup
require 'sinatra/base'
require 'nokogiri'
require 'builder'
require 'carPremiumCalculator'
require 'lifePremiumCalculator'

class CalculatorService < Sinatra::Base
  # Exception classes that are translated into SOAP faults
  module SoapFault
    class MustUnderstandError < StandardError
      def fault_code
        "MustUnderstand"
      end
    end

    class ClientError < StandardError
      def fault_code
        "Client"
      end
    end
  end

  set :root, File.dirname(__FILE__)

  configure do
    # SOAP requires SOAP messages to have Content-Type text/xml (the
    # Sinatra default is application/xml)
    mime_type :xml, "text/xml"
  end

  def initialize(*args)
    puts "\nReading xsd\n"
    @xsd = Nokogiri::XML::Schema(File.read("#{File.dirname(__FILE__)}/public/calculator_service.xsd"))
    puts "\nReading xslt\n"
    @xslt = Nokogiri::XSLT(File.read("#{File.dirname(__FILE__)}/lib/soap_body.xslt"))
    super
  end

  # SOAP endpoint
  post '/calculator_service' do
    begin
      soap_message = Nokogiri::XML(request.body.read)
      
      # Extract the SOAP body from SOAP envelope using XSLT
      soap_body = @xslt.transform(soap_message)
      
      # Validate the content of the SOAP body using the XML schema that is used
      # within the WSDL
      errors = @xsd.validate(soap_body).map{|e| e.message}.join(", ")
      
      # If the content of the SOAP body does not validate generate a SOAP fault
      # with fault_code Client (indicating the message failed due to a client
      # error)
      raise(SoapFault::ClientError, errors) unless errors == ""
      
      # Attempt to determine the SOAP operation and process it
      self.send(soap_operation_to_method(soap_body), soap_body)
      
    rescue StandardError => e
      # If any exception was raised generate a SOAP fault, if there is no
      # fault_code present then default to fault_code Server (indicating the
      # message failed due to an error on the server)
      fault_code = e.respond_to?(:fault_code) ? e.fault_code : "Server"
      halt(500, builder(:fault, :locals => {:fault_string => e.message, :fault_code => fault_code}))
    end
  end

  # Serve the WSDL. If the BASE_URL environmental variable is set then use
  # that to form the endpoint URL, otherwise default to localhost with
  # request port number
  get '/calculator_service/wsdl' do
    puts "\nProcessing request for wsdl\n"
    url = ENV['BASE_URL'] || "https://taigircalculatorservicesoap.herokuapp.com"
    erb(:calculator_service_wsdl, :locals => {:url => url}, :content_type => :xml)
  end

  private

  # Detect the SOAP operation based on the root element in the SOAP body
  def soap_operation_to_method(soap_body)
    method = soap_body.root.name.sub(/Request$/, '').gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase.to_sym
  end

  # Car Premium operation
  def car_premium(soap_body)
    age = soap_body.root.at_xpath('//calculator:age/text()', 'calculator' => 'http://www.hans.com/calculator').to_s.to_i
    make = soap_body.root.at_xpath('//calculator:make/text()', 'calculator' => 'http://www.hans.com/calculator').to_s
    year = soap_body.root.at_xpath('//calculator:year/text()', 'calculator' => 'http://www.hans.com/calculator').to_s.to_i
    gender = soap_body.root.at_xpath('//calculator:gender/text()', 'calculator' => 'http://www.hans.com/calculator').to_s
    state = soap_body.root.at_xpath('//calculator:state/text()', 'calculator' => 'http://www.hans.com/calculator').to_s
    builder(:car_premium_response, :locals => {:message => getCarPremium(age, make, year, gender, state)})
  end

  # Life Premium operation
  def life_premium(soap_body)
    age = soap_body.root.at_xpath('//calculator:age/text()', 'calculator' => 'http://www.hans.com/calculator').to_s.to_i
    occupationCategory = soap_body.root.at_xpath('//calculator:occupationCategory/text()', 'calculator' => 'http://www.hans.com/calculator').to_s
    gender = soap_body.root.at_xpath('//calculator:gender/text()', 'calculator' => 'http://www.hans.com/calculator').to_s
    state = soap_body.root.at_xpath('//calculator:state/text()', 'calculator' => 'http://www.hans.com/calculator').to_s
    builder(:life_premium_response, :locals => {:message => getLifePremium(age, occupationCategory, gender, state)})
  end
  
  def getLifePremium(age, occupationCategory, gender, state)
    return LifePremiumCalculator.new.getPremium(age, occupationCategory, gender, state).to_s
  end
  
  def getCarPremium(age, make, year, gender, state)
    return CarPremiumCalculator.new.getPremium(age, make, year, gender, state).to_s
  end
  
end
