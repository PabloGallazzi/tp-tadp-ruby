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

  def with(*args, &block)
    map = {}
    bool = args.all? do |matcher|
      matcher.bind(valor, map)
      matcher.call(valor)
    end
    if bool
      Executor.new(map,block).execute
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

  def call
    proc.call
    true
  end
end

class Executor
  attr_accessor :list, :proc

  def initialize(list, proc)
    self.proc = proc
    self.list = list
  end

  def execute()
    list.each{|key,value|define_singleton_method(key.to_sym) {value}}
    instance_eval &proc
    raise TodoEstaBienError
  end
end

class ListPattern
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

  def bind(val, map)
    map
  end

  def compare(val1, val2)
    comparison = false
    val1.each_with_index { |val, index|
      value = val2[index]
      if val.methods.include? :call
        comparison = val.call(value)
      else
        comparison = val.equal? value
      end
    }
    comparison
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

  def bind(val, map)
    map
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

  def bind(val, map)
    map
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

  def bind(val, map)
    map
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

  def bind(val, map)
    one.bind(val, map)
    another.bind(val, map)
    map
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

  def bind(val, map)
    one.bind(map)
    another.bind(map)
    map
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

  def bind(val, map)
    one.bind(val, map)
    map
  end
end

class Symbol
  def call(val)
    true
  end

  def bind(val, map)
    map[self] = val
    map
  end
end

class TodoEstaBienError < StandardError
end