module PatternMatching

  def valAlternativo(value)
    Proc.new { |n| n==value }
  end

  def val(value)
    ValPattern.new value
  end

  def type(value)
    TypePattern.new value
  end

  def duck(*values)
    DuckPattern.new values
  end

  def list(*values)
    ListPattern.new(values[0], values[1])
  end

  def with(*args, &block)
    WithPattern.new(args, block)
  end

  def otherwise(&block)
    OtherwisePattern.new(block)
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

class OtherwisePattern
  attr_accessor :proc

  def initialize(proc)
    self.proc = proc
  end

  def call(value)
    proc.call
    true
  end
end

class WithPattern
  attr_accessor :list, :proc

  def initialize(list, proc)
    self.proc = proc
    self.list = []
    self.list += list
  end

  def call(value)
    bool = list.all? do |matcher|
      matcher.call(value)
    end
    if bool
      proc.call
    end
    bool
  end
end

class ListPattern
  include Combinator
  attr_accessor :list, :size_bool

  def initialize(list, size)
    self.list = list
    self.size_bool = size
  end

  def call(value)
    if self.size_bool
      self.list.eql? value if self.list.count == value.count
    else
      if self.list.count > value.count
        new_list = self.list.first value.count
        value.eql? new_list
      else
        new_list = value.first self.list.count
        self.list.eql? new_list
      end
    end
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