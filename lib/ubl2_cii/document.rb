# frozen_string_literal: true

require 'nokogiri'

module Ubl2Cii
  class Document
    attr_reader :node, :namespaces

    def initialize(xml)
      @doc = Nokogiri::XML(xml, nil, OUTPUT_ENCODING) do |config|
        config.noblanks  # Remove blank nodes
        config.recover   # Try to parse even if there are errors
      end
      @node = @doc
      @namespaces = {
        PREFIX_RSM => NAMESPACE_RSM,
        PREFIX_RAM => NAMESPACE_RAM,
        PREFIX_UDT => NAMESPACE_UDT,
        PREFIX_CBC => NAMESPACE_CBC,
        PREFIX_CAC => NAMESPACE_CAC
      }

      raise ArgumentError, "Invalid XML: Document is empty" if @doc.root.nil?
    end

    def xpath(path, multiple: false)
      return unless @node

      if multiple
        @node.xpath(path, @namespaces)
      else
        @node.at_xpath(path, @namespaces)
      end
    end

    alias at_xpath xpath

    def content_at(path)
      xpath(path)&.content
    end

    def attribute_at(path, attr)
      xpath(path)&.[](attr)
    end

    def map_nodes(path, &)
      xpath(path, multiple: true).map(&)
    end

    def self.new_from_node(node, namespaces)
      doc = Document.allocate
      doc.instance_variable_set(:@node, node)
      doc.instance_variable_set(:@doc, node.document || node)
      doc.instance_variable_set(:@namespaces, namespaces)
      doc
    end
  end
end
