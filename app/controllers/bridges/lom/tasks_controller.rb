# frozen_string_literal: true

module Bridges
  module Lom
    class TasksController < ActionController::API
      OML_SCHEMA_PATH = 'vendor/assets/schemas/lom_1484.12.3-2020/lom.xsd'

      def show
        task = Task.find(params[:id])

        if task.lom_showable_by?(current_user)
          render xml: Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| LomService::ExportLom.call(task:, xml:) }
        else
          render xml: Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| xml.error 'Access Denied' }, status: :forbidden
        end
      end
    end
  end
end
