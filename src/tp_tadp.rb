module PatternMatching

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

  def with(*values, &block)
    binder_map = {}
    bool = values.all? do |matcher|
      matcher.bind_and_call(valor, binder_map)
    end
    if bool
      Executor.new(binder_map, block).execute
    end
    bool
  end

  def otherwise(&block)
    block.call
    raise TodoEstaBienError
  end

  def matches (val, &block)
    Matches.new(val, block).execute
  end

end

private

module Binder
  def bind(val, binder_map)
  end

  def bind_and_call(value, binder_map)
    bind(value, binder_map)
    call(value)
  end
end

class Symbol
  include Binder

  def call(val)
    true
  end

  def bind(val, binder_map)
    binder_map[self] = val
  end
end

class Matches
  include PatternMatching
  attr_accessor :proc, :valor

  def initialize(val, proc)
    self.valor=val
    self.proc = proc
  end

  def execute
    begin
      self.instance_eval &proc
    rescue TodoEstaBienError
      return true
    end
    false
  end
end

class Executor
  attr_accessor :list, :proc

  def initialize(list, proc)
    self.proc = proc
    self.list = list
  end

  def execute()
    list.each { |key, value| define_singleton_method(key) { value } }
    instance_eval &proc
    raise TodoEstaBienError
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

class ListPattern
  include Binder
  include Combinator
  attr_accessor :list, :size_bool

  def initialize(list, size)
    self.list = list
    size == nil ? self.size_bool = true : self.size_bool = size
  end

  def call(value)
    if self.size_bool
      self.list.count == value.count ? compare(self.list, value) : false
    else
      if self.list.count > value.count
        new_list = self.list.first value.count
        compare(new_list, value)
      else
        new_list = value.first self.list.count
        compare(self.list, new_list)
      end
    end
  end

  def compare(val1, val2)
    comparison = false
    val1.each_with_index { |val, index|
      value = val2[index]
      if val.respond_to? :call
        comparison = val.call(value)
      else
        comparison = val.eql? value
      end
    }
    comparison
  end

  def bind(val, binder_map)
    call = call(val)
    if (call)
      self.list.each { |it|
        it.bind(val, binder_map)
      }
    end
  end
end

class DuckPattern
  include Binder
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
  include Binder
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
  include Binder
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
  include Binder
  include Combinator
  attr_accessor :one, :another

  def initialize(one, another)
    self.one = one
    self.another = another
  end

  def call(val)
    one.call(val) && another.call(val)
  end

  def bind(val, binder_map)
    call = call(val)
    if (call)
      one.bind(val, binder_map)
      another.bind(val, binder_map)
    end
  end
end

class OrCombinator
  include Binder
  include Combinator
  attr_accessor :one, :another

  def initialize(one, another)
    self.one = one
    self.another = another
  end

  def call(val)
    one.call(val) || another.call(val)
  end

  def bind(val, binder_map)
    call_one = one.call(val)
    if (call_one)
      one.bind(val, binder_map)
      return call_one
    end
    call_another = one.call(val)
    if (call_another)
      one.bind(val, binder_map)
      return call_another
    end
    false
  end
end

class NotCombinator
  include Binder
  include Combinator
  attr_accessor :one

  def initialize(one)
    self.one = one
  end

  def call(val)
    !one.call(val)
  end

  def bind(val, binder_map)
    one.bind(val, binder_map)
  end
end

class TodoEstaBienError < StandardError
end