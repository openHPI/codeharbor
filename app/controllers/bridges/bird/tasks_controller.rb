# frozen_string_literal: true

module Bridges
  module Bird
    class TasksController < ActionController::API
      def index
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') {|xml| build_bird(xml) }
        render xml: builder
      end

      private

      def build_bird(xml)
        xml.import(
          xmlns: 'https://www.mathplan.de/moses/xsd/default',
          'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance'
        ) do
          bird_academy(xml)
          bird_courses(xml)
        end
      end

      def bird_academy(xml)
        xml.list(type: 'bird_academy') do
          xml.bird_academy do
            xml.id_ codeharbor_id
            xml.name 'CodeHarbor: Your repository for auto-gradeable programming exercises'
            xml.kurzname 'CodeHarbor'
          end
        end
      end

      def bird_courses(xml)
        xml.list(type: 'bird_course') do
          tasks.each.with_index do |task, i|
            xml.bird_course do
              xml.id_ task_url(id: "sample-#{i + 1}") # TODO: This needs to be replaced with the actual task id.
              xml.name task.title
              xml.academyId codeharbor_id
              xml.lectureType 'Programming Exercise'
            end
          end
        end
      end

      def codeharbor_id
        root_url
      end

      def tasks
        # TODO: Replace with DB query.
        @tasks ||= [
          Task.new(
            title: 'Hello World in Java',
            description: 'Write a simple program that prints "Hello World".',
            internal_description: 'This is a simple exercise for your students to begin with Java.',
            language: 'English'
          ),
          Task.new(
            title: 'Hello World in Python',
            description: 'Write a simple program that prints "Hello World".',
            internal_description: 'This is a simple exercise for your students to begin with Python.',
            language: 'English'
          ),
        ]
      end
    end
  end
end
