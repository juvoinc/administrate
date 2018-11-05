module Administrate
  class Namespace
    def initialize(namespace, engine_namespace = nil)
      @namespace = namespace
      @engine_namespace = engine_namespace
    end

    def resources
      @resources ||= routes.map(&:first).uniq.map do |path|
        Resource.new(namespace, path)
      end
    end

    def routes
      if engine_namespace
        search_string = "#{engine_namespace}/#{namespace}"
        regex_search_string = /^#{engine_namespace}\/#{namespace}\//
      else
        search_string = "#{namespace}/"
        regex_search_string = /^#{namespace}\//
      end

      @routes ||=
        all_routes.select do |controller, _action|
          controller.starts_with?(search_string)
        end.map do |controller, action|
          [controller.gsub(regex_search_string, ""), action]
        end
    end

    private

    attr_reader :namespace, :engine_namespace

    def all_routes
      app =
        if engine_namespace
          "#{engine_namespace.classify}::Engine".constantize.routes
        else
          Rails.application.routes
        end

      app.routes.map do |route|
        route.defaults.values_at(:controller, :action).map(&:to_s)
      end
    end
  end
end
