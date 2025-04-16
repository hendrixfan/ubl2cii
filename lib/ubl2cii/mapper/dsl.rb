# frozen_string_literal: true

module Ubl2Cii
  module Mapper
    class Dsl
      def self.element(name, options={}, &)
        element_def = {name: name}.merge(options)
        if block_given?
          new_class = Class.new(NestedMapping)
          new_class.class_eval(&)
          element_def[:children] = new_class
        end
        elements << element_def
      end

      def self.elements
        @elements ||= []
      end

      def self.collection(name, options={}, &)
        collection_def = {name: name, collection: true}.merge(options)
        if block_given?
          new_class = Class.new(NestedMapping)
          new_class.class_eval(&)
          collection_def[:item_mapping] = new_class
        end
        elements << collection_def
      end

      def process(xml, document, parent_prefix=nil)
        self.class.elements.each do |element_def|
          if element_def[:collection]
            build_collection(xml, document, element_def, parent_prefix)
          else
            build_element(xml, document, element_def, parent_prefix)
          end
        end
      end

      private

      def build_element(xml, document, element_def, parent_prefix)
        prefix = element_def[:prefix] || parent_prefix || PREFIX_RAM
        attributes = build_attributes(document, element_def)

        if element_def[:children]
          build_nested_element(xml, document, element_def, prefix)
        else
          build_simple_element(xml, document, element_def, prefix, attributes)
        end
      end

      def build_attributes(document, element_def)
        attributes = {}
        if element_def[:source_properties]
          attributes.merge!(handle_properties(element_def[:source_properties], element_def[:source], document))
        end
        attributes.merge!(handle_properties(element_def[:properties], document)) if element_def[:properties]
        attributes
      end

      def build_nested_element(xml, document, element_def, prefix)
        source_doc = element_def[:source] ? extract_node(document, element_def[:source]) : document
        xml[prefix].send(element_def[:name]) do
          element_def[:children].new.process(xml, source_doc, prefix)
        end
      end

      def build_simple_element(xml, document, element_def, prefix, attributes)
        value = extract_value(document, element_def[:source])
        value = handle_value_format(value, element_def[:name]) if FORMATABLE_ELEMENTS.include?(element_def[:name])
        xml[prefix].send(element_def[:name], value, attributes)
      end

      def handle_properties(properties, source = nil, document)
        resolved_properties = {}
        properties.each do |key, value|
          resolved_properties[key] = if value.is_a?(Proc)
                                       extract_value(document, value.call)
                                     else
                                       document.attribute_at(source, key) || value
                                     end
        end
        resolved_properties
      end

      def handle_value_format(value, element_name)
        return unless value

        case element_name
        when 'DateTimeString'
          date_value = begin
            DateTime.parse(value)
          rescue StandardError
            nil
          end
          date_value&.strftime('%Y%m%d')
        else
          value
        end
      end

      def build_collection(xml, document, element_def, parent_prefix)
        prefix = element_def[:prefix] || parent_prefix || PREFIX_RAM
        items = extract_nodeset(document, element_def[:source]) || []

        items.each do |item|
          xml[prefix].send(element_def[:name]) do
            element_def[:item_mapping]&.new&.process(xml, item, prefix)
          end
        end
      end

      def extract_nodeset(document, source)
        return nil unless source

        document.map_nodes(source) {|node| Document.new_from_node(node, document.namespaces) }
      end

      def extract_node(document, source)
        return nil unless source

        Document.new_from_node(document.at_xpath(source), document.namespaces)
      end

      def extract_value(document, source)
        return nil unless source

        case source
        when String
          document.content_at(source)
        when Proc
          source.call(document)
        when Symbol
          document.send(source) if document.respond_to?(source)
        end
      end
    end

    # For nested mappings within elements
    class NestedMapping < Dsl
    end
  end
end
