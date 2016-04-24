module Matcher
  def val(value)
    ValPattern.new value
  end

  def type(value)
    TypePattern.new value
  end

  def duck(*values)
    DuckPattern.new values
  end
end

module Combinator
  def and(other)
    AndCombinator.new(self, other)
  end

  def or(other)
    OrCombinator.new(self, other)
  end

  def not
    NotCombinator.new(self)
  end
end

class DuckPattern
  include Combinator
  attr_accessor :val

  def initialize(val)
    self.val = val
  end

  def call(value)
    val.all? do |sym|
      value.methods.include? sym
    end
  end
end

class ValPattern
  include Combinator
  attr_accessor :val

  def initialize(val)
    self.val = val
  end

  def call(value)
    self.val.eql? value
  end
end

class TypePattern
  include Combinator
  attr_accessor :type

  def initialize(type)
    self.type = type
  end

  def call(type)
    type.is_a? self.type
  end
end

class AndCombinator
  include Combinator
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
  include Combinator
  attr_accessor :one, :another

  def initialize(one, another)
    self.one = one
    self.another = another
  end

  def call(val)
    one.call(val) || another.call(val)
  end
end

class NotCombinator
  include Combinator
  attr_accessor :one

  def initialize(one)
    self.one = one
  end

  def call(val)
    !one.call(val)
  end
end


module Pattern
  include Matcher
  attr_accessor :matches
  def initialize
    @matches = []
  end
  def with(*matcher, &block)
    @matchers += matcher
    self.call(block) unless
        @matchers.all? do |a,b|
          !(a.and(b))
        end
  end
end


