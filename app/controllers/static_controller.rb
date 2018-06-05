class StaticController < ApplicationController

  def about
  end

  def positions
  end

  def position
  end

  def defined_position
    pathname = request.path.gsub(/\/\z/, '')
    @route = StaticRoutes.new.route_map[pathname]
  end
end
