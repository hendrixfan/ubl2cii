# frozen_string_literal: true

require 'nokogiri'
require 'date'

module Ubl2Cii
  class Converter
    def initialize(xml)
      @document = Document.new(xml)
    end

    def convert_to_cii
      builder = Nokogiri::XML::Builder.new(encoding: OUTPUT_ENCODING) do |xml|
        xml[PREFIX_RSM].CrossIndustryInvoice(namespaces) do
          Mapper::Cii.new.process(xml, @document)
        end
      end
      clean_empty_elements(builder.doc)
      builder.to_xml.force_encoding(OUTPUT_ENCODING)
    end

    private

    def clean_empty_elements(node)
      pending = node.children.to_a
      while element = pending.pop
        pending.concat(element.children.to_a)

        next if !element.element? || REQUIRED_ELEMENTS.include?(element.name)

        element.remove if element.children.empty? && element.attributes.empty?
      end
      node
    end

    def namespaces
      @namespaces ||= {
        "xmlns:#{PREFIX_QDT}" => NAMESPACE_QDT,
        "xmlns:#{PREFIX_RSM}" => NAMESPACE_RSM,
        "xmlns:#{PREFIX_UDT}" => NAMESPACE_UDT,
        "xmlns:#{PREFIX_RAM}" => NAMESPACE_RAM
      }
    end
  end
end
