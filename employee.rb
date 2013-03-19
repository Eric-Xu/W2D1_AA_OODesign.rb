#Note to reviewer: we accidentally calculated a manager's bonus
#by calling calculate_bonus on it's employees, whereas we should
#have just added the employees' salaries.

require 'debugger'

class Employee
  attr_reader :name, :title, :salary, :boss

  def initialize(name, title, salary)
    @name = name
    @title = title
    @salary = salary
    @boss = nil
  end

  def boss=(boss)
    @boss = boss
  end

  def calculate_bonus(multiplier)
    @salary * multiplier
  end
end

class Manager < Employee
  def initialize(name, title, salary)
    super(name, title, salary)
    @employees = []
  end

  def assign_employee(employee)
    @employees << employee
    employee.boss = self
  end

  def calculate_bonus(multiplier)
    employee_sum = 0
    @employees.each do |employee|
      employee_sum += employee.calculate_bonus(multiplier)
    end
    puts @employee_sum

    if @boss == nil
      puts "I have no boss"
      return (employee_sum * multiplier)
    else
      puts "I have a boss"
      return (employee_sum * multiplier) + @salary
    end
  end
end


