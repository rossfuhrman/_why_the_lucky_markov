require "roda"


class Main < Roda
  plugin :render
  plugin :head
  route do |r|
    r.root do
      r.run CampingApp
    end
  end
end
