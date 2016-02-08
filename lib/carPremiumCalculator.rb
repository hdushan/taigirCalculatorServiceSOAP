class CarPremiumCalculator

  def initialize
    @basePremium = 10
    @ageFactor = 1.2
    @genderFactors = {"male" => 1.25, "female" => 1.15}
    @stateFactors = {"nsw" => 1.1, "vic" => 1.2, "sa" => 1.3, "wa" => 1.4, "tas" => 1.5, "qld" => 1.6}
    @makeFactors = {"audi" => 1.0, "alfa" => 1.1, "bmw" => 1.2, "lexus" => 1.3, "toyota" => 1.4, "vw" => 1.5}
  end

  def getPremium(age, make, year, gender, state)
    ('%.2f'%(@basePremium + @ageFactor*age.to_f*@genderFactors[gender]*@stateFactors[state]*@makeFactors[make]))
  end
  
end