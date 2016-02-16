class Person
  include RollsDice
  attr_reader :given_name, :family_name, :alive, :age, :child_bearing, :religion, :pregnant
  attr_reader :cause_of_death, :year_of_death, :year_of_birth, :months_until_birth
  attr_accessor :health

  def initialize(religion, family_name=Faker::Name.last_name, year=nil)
    @given_name = Faker::Name.first_name
    @family_name  = family_name
    @health = 175 + d(50)
    @alive = true
    @child_bearing = [true, false].sample
    @religion = religion
    if year
      @year_of_birth = year
      @age = 0
    else
      @age = d(70)
      @year_of_birth = -age
    end

    @species_preferences = religion.world.species.sort_by do |s|
      religion.policies.find_all {|p| p.subject == s}.map { |p| p.consequence.weight }.reduce(:+) || 0
    end
  end

  def alive?; alive; end

  def kill!(cause_of_death, year)
    @alive = false
    @cause_of_death = cause_of_death
    @year_of_death = year
  end

  def tick(world)
    eat(world)
    reproduce!(world.year)
    age!(world.year)
    kill!("freak accident!", world.year) if d(100) > 98 # 20K micromorts / year
    kill!("sickness", world.year) if health <= 0
  end

  def eat(world)
    species = (@species_preferences & world.species).first
    policy = religion.policies.find {|p| p.subject == species}
    # TODO add disease here
    if world.active_event.affected_species.include?(species)
      subtract_health(world.active_event.severity,"plague on #{species}", world.year)
    end
    if policy
      # TODO inflict penalty...
      if policy.consequence.death?
        kill!("punishment for eating #{species}", world.year)
      end
    end
  end

  def age!(year)
    @age += 1
    if (age > 45 && health > 10) || age < 80
      subtract_health(1, :old_age, year)
    else
      @health += 1
    end
  end

  def subtract_health(int, reason, year)
    return unless alive?
    @health -= int
    if health <= 0
      kill!(reason, year)
    end
  end

  def reproduce!(year)
    return unless alive?
    if pregnant
      @pregnant = false
      case d(100)
      when 1..20
        religion.add_member(Person.new(religion, child_name, year))
      when 21..90
        nil
      else
        kill!("bad :(", year)
      end
    elsif (age >= minimum_pregnancy_age && age <= maximum_pregnancy_age) && child_bearing
      @pregnant = true
    end
  end

  def child_name
    case d(4)
    when 1
      "O'#{family_name}"
    when 2
      "Mc#{family_name}"
    when 3
      "#{family_name}son"
    when 4
      "#{family_name}dottir"
    end
  end

  def minimum_pregnancy_age; 20; end
  def maximum_pregnancy_age; 45; end

  def to_s
    if child_bearing
      if pregnant
        pregnancy = "pregnant"
      elsif age < minimum_pregnancy_age
        pregnancy = "child"
      elsif age > maximum_pregnancy_age
        pregnancy = "elder"
      else
        pregnancy = "not_pregnant"
      end
    else
      pregnancy = "not_child_bearing"
    end
    "          #{given_name} #{family_name}:#{age}:#{pregnancy}"
  end
end