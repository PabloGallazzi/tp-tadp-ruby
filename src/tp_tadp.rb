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
    self.val.eql? value
  end

  def and(other)
    AndCombinator.new(self, other)
  end
  def or(other)
    OrCombinator.new(self, other)
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

  def and(other)
    AndCombinator.new(self, other)
  end
  def or(other)
    OrCombinator.new(self, other)
  end
end

class AndCombinator
  attr_accessor :one, :another

  def initialize(one, another)
    self.one = one
    self.another = another
  end

  def call(val)
    one.call(val) && another.call(val)
  end
end

class OrCombinator
  attr_accessor :one, :another

  def initialize(one, another)
    self.one = one
    self.another = another
  end

  def call(val)
    one.call(val) || another.call(val)
  end
end

class Pinga
  include Matcher

  def a
    val(5).and(type(Fixnum)).call(5)
  end
  def a1
    val("Hola").and(type(String)).call("Hola")
  end
  def a2
    val(5).and(type(String)).call(5)
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