class Policy

  attr_reader :subject, :consequence
  def initialize(world)
    @subject = world.species.sample
    @consequence = Consequence.all.sample
  end

  def inspect
    "#{subject.inspect} => #{consequence.inspect}"
  end
end
class Consequence

  def self.all
    [new(:death, 100), new(:imprisonment, 75), new(:beating, 60), new(:penance, 20), new(:ostracization, 5)]
  end

  attr_reader :name, :weight
  def initialize(name, weight)
    @name = name
    @weight = weight
  end

  def death?; name == :death; end

  def inspect
    "[#{name}, #{weight}]"
  end
end
