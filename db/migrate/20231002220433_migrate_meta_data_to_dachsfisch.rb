# frozen_string_literal: true

class MigrateMetaDataToDachsfisch < ActiveRecord::Migration[7.0]
  def change
    Task.where.not(meta_data: nil).in_batches&.each {|tasks| update_meta_data tasks }
    Test.where.not(meta_data: nil).in_batches&.each {|tests| update_meta_data tests }
    change_column_null :tasks, :meta_data, false, {}
  end

  def update_meta_data(batch)
    batch.each do |object|
      object.meta_data = transform_meta_data(object.meta_data)
      object.save!(touch: false)
    end
  end

  def transform_meta_data(task_meta_data)
    fragment = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
    Nokogiri::XML::Builder.with fragment do |xml|
      xml.send(:'meta-data', 'xmlns:CodeOcean' => 'codeocean.openhpi.de') { meta_data(xml, task_meta_data) }
    end

    xml = fragment.elements.deconstruct.map(&:to_xml).join
    JSON.parse(Dachsfisch::XML2JSONConverter.perform(xml:))
  end

  def meta_data(xml, meta_data)
    meta_data.each do |namespace, data|
      inner_meta_data(xml, namespace, data)
    end
  end

  def inner_meta_data(xml, namespace, data)
    data.each do |key, value|
      case value.class.name
        when 'Hash'
          # underscore is used to disambiguate tag names from ruby methods
          xml[namespace].send("#{key}_") do |meta_data_xml|
            inner_meta_data(meta_data_xml, namespace, value)
          end
        else
          xml[namespace].send("#{key}_", value)
      end
    end
  end
end

class Task < ApplicationRecord
end

class Test < ApplicationRecord
end
