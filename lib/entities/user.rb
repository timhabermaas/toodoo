class User
  attr_accessor :name, :id, :password

  def initialize attributes={}
    attributes.each do |key, value|
      instance_name = "@#{key}"
      instance_variable_set instance_name.to_sym, value
    end
  end

  def == other
    other.id == self.id && other.name == self.name
  end
end
