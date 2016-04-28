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

  it 'call to a symbol returns true' do
    expect(:un_symbol.call 5).to eq(true)
  end

  it 'matcher for otherwise as in the example' do
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

  it 'otherwise should respond true and execute' do
    expect(otherwise { puts 'Tiene que salir por acá!' }.call(5)).to eq(true)
  end

  it 'with should execute block passed' do
    expect(with(val(5).and(:a), type(Fixnum)) { puts 'Tiene que salir por acá!' }.call(5)).to eq(true)
  end

  it 'with should not execute block passed' do
    expect(with(val(5), type(String)) { raise 'NO tiene que salir por acá!' }.call(5)).to eq(false)
  end

  it '5 es valAlternativo(5)' do
    expect(valAlternativo(5).call(5)).to eq(true)
  end
  it 'un_test tiene a' do
    expect(duck(:a, :a1).call(un_test)).to eq(true)
  end
  it 'un_test no tiene b' do
    expect(duck(:a, :b).call(un_test)).to eq(false)
  end
  it '5 es val(5)' do
    expect(val(5).call(5)).to eq(true)
  end
  it '5 es type(Fixnum)' do
    expect(type(Fixnum).call(5)).to eq(true)
  end
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
end