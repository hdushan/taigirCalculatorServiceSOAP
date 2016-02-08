class LifePremiumCalculator

  def initialize
    @basePremium = 10
    @ageFactor = 1.2
    @genderFactors = {"male" => 1.25, "female" => 1.15}
    @stateFactors = {"nsw" => 1.1, "vic" => 1.2, "sa" => 1.3, "wa" => 1.4, "tas" => 1.5, "qld" => 1.6}
    @occupationFactors = {"risk0" => 1.0, "risk1" => 1.1, "risk2" => 1.2, "risk3" => 1.3}
  end

  def getPremium(age, occupationCategory, gender, state)
    ('%.2f'%(@basePremium + @ageFactor*age.to_f*@genderFactors[gender]*@stateFactors[state]*@occupationFactors[occupationCategory]))
  end
  
end