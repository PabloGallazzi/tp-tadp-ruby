module Matcher
  def val(value)
    ValPattern.new value
  end

  def type(value)
    TypePattern.new value
  end
end

class Combinator
  attr_accessor :one, :another
  def and(one, another)
    AndCombinator.new(one, another)
  end
  def or (one, another)
    OrCombinator.new(one, another)
  end
end

class ValPattern < Combinator
  attr_accessor :val

  def initialize(val)
    self.val = val
  end

  def call(value)
    self.val.equal? value
  end
end

class TypePattern < Combinator
  attr_accessor :type

  def initialize(type)
    self.type = type
  end

  def call(type)
    type.is_a? self.type
  end
end

class AndCombinator
  attr_accessor :another

  def and(another)
    self.another = another
  end
  def evaluate(val)
  end
end

class OrCombinator
  attr_accessor :another
  def or
    self.another = another
  end
  def evaluate
  end
end

class Pinga
  include Matcher
  def a
    val(5).call(5)
  end
  def b
    type(Fixnum).call(5)
  end
  def c
    type(Fixnum).call("hola")
  end
  def d
    type(Fixnum).call("hola")
  end
end