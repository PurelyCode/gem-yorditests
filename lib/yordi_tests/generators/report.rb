require 'thor/group'
module YordiTests
  module Generators
    class Report < Thor::Group
      include Thor::Actions
      argument :report_path, type: :string
      argument :report_data, type: :hash, default: {name: 'Unknown'}

      def self.source_root
        File.dirname(__FILE__)
      end

      def create_report
        template("report.html.erb", report_path, force: true)
      end

    end
  end
end