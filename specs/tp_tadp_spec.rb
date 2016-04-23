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

  let(:un_test){
    Test.new
  }

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