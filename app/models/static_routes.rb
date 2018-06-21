# DSL for custom-routes defined in a text file

class StaticRoutes
  ROUTES_FILE = Rails.root.join('db/position_routes.txt')

  def route_paths
    routes.map {|route| route[:path] }
  end

  def route_map
    results = Rails.cache.read route_map_cache_key
    return results unless results.nil?
    route_map!
  end

  def route_map!
    results = Hash[routes.map {|route| [route[:path], route] }]
    Rails.cache.write route_map_cache_key, results
    results
  end

  private

  def route_map_cache_key
    "static_routes:route_map"
  end

  def routes
    open(ROUTES_FILE, 'r').read.split(/\n\n/).map do |route_data|
      route_data_rows = route_data.split(/\n/).map(&:strip)
      {
        title: route_data_rows[0],
        description: route_data_rows[1],
        path: route_data_rows[2],
        options: Hash[route_data_rows[3..-1].map {|row|
          k, v = row.split(":").map(&:strip)
          [k, v]
        }]
      }
    end
  end
end
