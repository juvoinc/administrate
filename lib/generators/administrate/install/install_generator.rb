require "rails/generators/base"
require "administrate/generator_helpers"
require "administrate/namespace"

module Administrate
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Administrate::GeneratorHelpers
      source_root File.expand_path("../templates", __FILE__)

      class_option :admin_namespace, type: :string, default: "admin"
      class_option :engine_namespace, type: :string, required: false

      def run_routes_generator
        if dashboard_resources.none?
          call_generator("administrate:routes", "--admin_namespace", admin_namespace)
          load Rails.root.join("config/routes.rb")
        end
      end

      def create_dashboard_controller
        location =
          if namespaced?
            "app/controllers/#{engine_namespace || namespaced_path}/#{admin_namespace}/application_controller.rb"
          else
            "app/controllers/#{admin_namespace}/application_controller.rb"
          end

        template("application_controller.rb.erb", location)
      end

      def run_dashboard_generators
        singular_dashboard_resources.each do |resource|
          call_generator "administrate:dashboard", resource,
            "--admin_namespace", admin_namespace
        end
      end

      private

      def admin_namespace
        options[:admin_namespace]
      end

      def singular_dashboard_resources
        dashboard_resources.map(&:to_s).map(&:singularize)
      end

      def dashboard_resources
        Administrate::Namespace.new(admin_namespace, engine_namespace).resources
      end
    end
  end
end
