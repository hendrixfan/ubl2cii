# frozen_string_literal: true

require 'nokogiri'

module Ubl2Cii
  class Document
    attr_reader :node, :namespaces

    def at_xpath(path)
      return unless @node

      @node.at_xpath(path, @namespaces)
    end

    def xpath(path)
      @node.xpath(path, @namespaces)
    end

    # Helper to get content from a node at xpath
    def content_at(path)
      at_xpath(path)&.content
    end

    # Helper to get an attribute from a node at xpath
    def attribute_at(path, attr)
      at_xpath(path)&.[](attr)
    end

    # Helper to get a new object if node exists at path
    def object_at(path, klass)
      found_node = at_xpath(path)
      klass.new(found_node, @namespaces) if found_node
    end

    # Helper to map nodes to objects
    def map_nodes(path, &)
      xpath(path).map(&)
    end

    def initialize(xml)
      @xml = xml
      @doc = Nokogiri::XML(xml, nil, OUTPUT_ENCODING)
      super(@doc, {
        PREFIX_RSM => NAMESPACE_RSM,
        PREFIX_RAM => NAMESPACE_RAM,
        PREFIX_UDT => NAMESPACE_UDT,
        PREFIX_CBC => NAMESPACE_CBC,
        PREFIX_CAC => NAMESPACE_CAC
      })
    end

    # Helper method to create documents from nodes
    def self.new_from_node(node, namespaces)
      doc = Document.allocate
      doc.instance_variable_set(:@node, node)
      doc.instance_variable_set(:@doc, node)
      doc.instance_variable_set(:@namespaces, namespaces)
      doc
    end
  end
end
