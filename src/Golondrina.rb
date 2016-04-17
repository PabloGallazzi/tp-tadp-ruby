class Golondrina

  attr_accessor :energia

  def initialize
    self.energia = 1000
  end

  def volar(km)
    self.energia -= 10 * km
  end

  def comer(grs)
    self.energia += 5 * grs
  end
end