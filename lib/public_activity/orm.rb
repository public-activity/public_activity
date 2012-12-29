module PublicActivity
  # TODO: Docs or sth
  module ORM
    Mapping = Class.new(Hash) do
      alias_method :register, :[]=
    end.new
  end
end
