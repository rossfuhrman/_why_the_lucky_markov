require "camping"
Camping.goes :CampingApp

module CampingApp::Controllers
  class Index < R '/'
    def get
      render :what_even_is_this
    end
  end
end

module CampingApp::Views
  def layout
    html do
      head do
        title { "_why the lucky markov" }
      end
      body { self << yield }
    end
  end

  def what_even_is_this
    p "some words"
  end
end
