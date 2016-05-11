require_relative '../src/tp_tadp'
require 'rspec'

describe 'PatternMatching' do
  include PatternMatching

  class Test
    def a
      true
    end

    def a1
      true
    end
  end

  let(:un_test) {
    Test.new
  }

  #Tests para type

  it 'type un_test returns true for class Test' do
    expect(type(Test).call(un_test)).to eq(true)
  end

  it 'type un_test returns true for class Object' do
    expect(type(Object).call(un_test)).to eq(true)
  end

  it 'type un_test returns false for class String' do
    expect(type(String).call(un_test)).to eq(false)
  end

  it '5 returns true for class Fixnum' do
    expect(type(Fixnum).call(5)).to eq(true)
  end

  #Tests para list

  it 'with symbols, val and or size requested, size ok, firsts ok, then true' do
    expect(list([:a, val(2), type(Fixnum).and(val(3))], true).call([1, 2, 3])).to eq(true)
  end

  it 'strings size requested, size ok, firsts ok, then true' do
    expect(list(['1', '2', '3'], true).call(['1', '2', '3'])).to eq(true)
  end

  it 'size requested, size ok, firsts ok, then true' do
    expect(list([1, 2, 3], true).call([1, 2, 3])).to eq(true)
  end

  it 'size not requested, size not ok, firsts ok, then true' do
    expect(list([1, 2, 3], false).call([1, 2])).to eq(true)
  end

  it 'size requested, size not ok, firsts ok, then false' do
    expect(list([1, 2, 3], true).call([1, 2])).to eq(false)
  end

  it 'size requested, size not ok, firsts ok, then false' do
    expect(list([1, 2, 3], true).call([1, 2, 3, 4])).to eq(false)
  end

  it 'size not requested, size not ok, firsts ok, then false' do
    expect(list([1, 2, 3], false).call([1, 2, 3, 4])).to eq(true)
  end

  it 'size implicitly requested, size not ok, firsts ok, then false' do
    expect(list([1, 2, 3]).call([1, 2])).to eq(false)
  end

  it 'size requested, size ok, firsts not ok, then false' do
    expect(list([1, 2, 3], true).call([1, 2, 4])).to eq(false)
  end

  it 'size requested, size not ok, firsts not ok, then false' do
    expect(list([1, 2, 3], true).call([1, 3, 4, 5])).to eq(false)
  end

  #Test para symbol

  it 'call to a symbol returns true' do
    expect(:un_symbol.call 5).to eq(true)
  end

  #Tests para duck

  it 'un_test tiene a' do
    expect(duck(:a, :a1).call(un_test)).to eq(true)
  end

  it 'un_test no tiene b' do
    expect(duck(:a, :b).call(un_test)).to eq(false)
  end

  it 'un proc tiene call' do
    expect(duck(:call).call(Proc.new {})).to eq(true)
  end

  it 'un object tiene to_s' do
    expect(duck(:to_s).call(Object.new)).to eq(true)
  end

  it 'un object no tiene a' do
    expect(duck(:a).call(Object.new)).to eq(false)
  end

  it 'un object tiene to_s pero no tiene a' do
    expect(duck(:to_s, :a).call(Object.new)).to eq(false)
  end

  #Tests para val

  it 'un_test es val(un_test)' do
    expect(val(un_test).call(un_test)).to eq(true)
  end

  it '5 es val(5)' do
    expect(val(5).call(5)).to eq(true)
  end

  it 'hola es val(hola)' do
    expect(val('hola').call('hola')).to eq(true)
  end

  it '3.509 es val(3.509)' do
    expect(val(3.509).call(3.509)).to eq(true)
  end

  #Tests para and, or y not

  it '5 es val(5) y type(Fixnum) todo eso not da false' do
    expect(val(5).and(type(Fixnum)).not.call(5)).to eq(false)
  end
  it '5 es val(5) y type(Fixnum)' do
    expect(val(5).and(type(Fixnum)).call(5)).to eq(true)
  end
  it '5 es val(5) o type(String)' do
    expect(val(5).or(type(String)).call(5)).to eq(true)
  end
  it '5 no es ni val(3) ni type(String)' do
    expect(val(3).or(type(String)).call(5)).to eq(false)
  end
  it 'Hola es val Hola y String o Fixnum' do
    expect(val("Hola").and(type(String)).or(type(Fixnum)).call("Hola")).to eq(true)
  end

  it '5 es ni val(5) pero no un type(String)' do
    expect(val(5).and(type(String)).call(5)).to eq(false)
  end

  #Tests para matches

  it 'matches no one' do
    matcherFor = matches (5) do
      with(val(5), type(String)) { raise 'No tiene que salir por acá!' }
      with(val('6'), type(Fixnum)) { raise 'No tiene que salir por acá!' }
    end
    expect(matcherFor).to eq(false)
  end

  it 'matcher for otherwise as in the example' do
    matcherFor1 = matches (5) do
      with(val(5), type(String)) { raise 'No tiene que salir por acá!' }
      with(val('6'), type(Fixnum)) { raise 'No tiene que salir por acá!' }
      otherwise { puts 'Tiene que salir por acá!' }
    end
    expect(matcherFor1).to eq(true)
  end

  it 'matcher as in the example' do
    matcherFor2 = matches (5) do
      with(val(5), type(Fixnum)) { puts 'Tiene que salir por acá!' }
      with(val(5), type(Fixnum)) { raise 'No tiene que salir por acá!' }
      otherwise { raise 'No tiene que salir por acá!' }
    end
    expect(matcherFor2).to eq(true)
  end

  it 'matcher witch do' do
    matcherFor3 = matches (5) do
      with(val(5), type(Fixnum)) do
        puts 'Tiene que salir por acá!'
      end
      with(val(5), type(Fixnum)) do
        raise 'No tiene que salir por acá!'
      end
      otherwise do
        raise 'No tiene que salir por acá!'
      end
    end
    expect(matcherFor3).to eq(true)
  end

  it 'matcher witch {' do
    matcher = matches (5) {
      with(val(5), type(Fixnum)) { puts 'Tiene que salir por acá!' }
      with(val(5), type(Fixnum)) { raise 'No tiene que salir por acá!' }
      otherwise { raise 'No tiene que salir por acá!' }
    }
    expect(matcher).to eq(true)
  end

  #Tests para binding

  it 'matcher with binding list' do
    matcherFor = matches (['Hola! yo me tengo que imprimir...']) do
      with(list([type(String).and(:a).or(:b)], false)) { puts a + b }
      with(val('6'), type(Fixnum)) { raise 'No tiene que salir por acá!' }
      otherwise { raise 'No tiene que salir por acá!' }
    end
    expect(matcherFor).to eq(true)
  end

  it 'matcher with binding' do
    matcherFor = matches ('Hola! yo me tengo que imprimir...') do
      with(val('Hola! yo me tengo que imprimir...'), type(String), :a) { puts a }
      with(val('6'), type(Fixnum)) { raise 'No tiene que salir por acá!' }
      otherwise { raise 'No tiene que salir por acá!' }
    end
    expect(matcherFor).to eq(true)
  end

  it 'matcher with binding only to the left b does not bind' do
    matcherFor = matches ('Hola! yo me tengo que imprimir...') do
      with(val('Hola! yo me tengo que imprimir...'), type(String).and(val('Hola! yo me tengo que imprimir...')).or(type(Fixnum).and(:b)).and(type(String)), :a) {
        final_string = ''
        begin
          b
        rescue NameError
          final_string = a + ' Todo OK'
        end
        if !final_string.eql? 'Hola! yo me tengo que imprimir... Todo OK'
          raise 'b no debería estar bindeada!'
        end
        puts final_string
      }
      with(val('6'), type(Fixnum)) { raise 'No tiene que salir por acá!' }
      otherwise { raise 'No tiene que salir por acá!' }
    end
    expect(matcherFor).to eq(true)
  end

end