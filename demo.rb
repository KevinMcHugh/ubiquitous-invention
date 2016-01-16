class Person
  attr_reader :stress, :name, :alive
  attr_accessor :religion

  def initialize
    @name = Faker::Name.name
    @stress = 0
    @alive = true
  end

  def alive?
    alive
  end

  def kill!
    @alive = false
  end
end

class Religion
  attr_reader :name, :faithful, :policies
  def initialize(name)
    @name = name
    @faithful = 100.times.map { Person.new }
    @faithful.each { |f| f.religion = self }
    @policies = 3.times.map { Policy.new }
  end

  def inspect
    "Religion #{name}, \n" +
      "     Policies #{policies.map(&:inspect)}\n" +
      "Alive: #{faithful.count(&:alive?)}/ #{faithful.count}"
  end
end

class Policy
  def self.acts
    [:eat_pork, :eat_beef, :eat_vegetarian, :eat_dairy, :eat_seafood]
  end

  def self.consequences
    [0, 1, 5, 10, 50]
  end

  def initialize
    @act = self.class.acts.sample
    @consequence = self.class.consequences.sample
  end

  def inspect
    "#{@act} => #{@consequence}"
  end
end

require 'faker'
require 'pp'
require 'pry'
religions = 5.times.map do
  r = Religion.new(Faker::App.name)
  pp r
  r
end
binding.pry

100.times do |i|

end