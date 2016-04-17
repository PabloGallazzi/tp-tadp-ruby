require_relative '../src/Golondrina'
require 'rspec'

describe 'golondrinas' do

  let(:una_golondrina){
    Golondrina.new
  }

  it 'pierde si vuela' do
    una_golondrina.volar(10)
    expect(una_golondrina.energia).to eq(900)
  end

  it 'gana si come' do
    una_golondrina.comer(10)
    expect(una_golondrina.energia).to eq(1050)
  end
end