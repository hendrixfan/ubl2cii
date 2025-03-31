# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'

describe Ubl2Cii::Document do
  let(:simple_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
              xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
              xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">
        <cbc:ID>INVOICE-001</cbc:ID>
        <cbc:IssueDate>2025-04-13</cbc:IssueDate>
        <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
        <cac:AccountingSupplierParty>
          <cac:Party>
            <cbc:EndpointID schemeID="0088">supplier-id</cbc:EndpointID>
            <cac:PartyName>
              <cbc:Name>Supplier Name</cbc:Name>
            </cac:PartyName>
            <cac:PostalAddress>
              <cbc:StreetName>Main Street</cbc:StreetName>
              <cbc:CityName>Brussels</cbc:CityName>
              <cbc:PostalZone>1000</cbc:PostalZone>
              <cac:Country>
                <cbc:IdentificationCode>BE</cbc:IdentificationCode>
              </cac:Country>
            </cac:PostalAddress>
          </cac:Party>
        </cac:AccountingSupplierParty>
        <cac:InvoiceLine>
          <cbc:ID>1</cbc:ID>
          <cbc:LineExtensionAmount currencyID="EUR">100.00</cbc:LineExtensionAmount>
        </cac:InvoiceLine>
        <cac:InvoiceLine>
          <cbc:ID>2</cbc:ID>
          <cbc:LineExtensionAmount currencyID="EUR">50.00</cbc:LineExtensionAmount>
        </cac:InvoiceLine>
      </Invoice>
    XML
  end

  let(:empty_xml) { '<Invoice></Invoice>' }
  let(:invalid_xml) { '<Invoice>' }

  describe '#initialize' do
    it 'creates a document from XML string' do
      doc = described_class.new(simple_xml)
      expect(doc).to be_a(described_class)
      expect(doc.instance_variable_get(:@doc)).to be_a(Nokogiri::XML::Document)
    end

    it 'handles empty XML' do
      doc = described_class.new(empty_xml)
      expect(doc).to be_a(described_class)
      expect(doc.instance_variable_get(:@doc)).to be_a(Nokogiri::XML::Document)
    end

    it 'initializes namespaces correctly' do
      doc = described_class.new(simple_xml)
      namespaces = doc.instance_variable_get(:@namespaces)

      expect(namespaces[Ubl2Cii::PREFIX_CBC]).to eq(Ubl2Cii::NAMESPACE_CBC)
      expect(namespaces[Ubl2Cii::PREFIX_CAC]).to eq(Ubl2Cii::NAMESPACE_CAC)
      expect(namespaces[Ubl2Cii::PREFIX_RSM]).to eq(Ubl2Cii::NAMESPACE_RSM)
      expect(namespaces[Ubl2Cii::PREFIX_RAM]).to eq(Ubl2Cii::NAMESPACE_RAM)
      expect(namespaces[Ubl2Cii::PREFIX_UDT]).to eq(Ubl2Cii::NAMESPACE_UDT)
    end

    it 'handles invalid XML without raising' do
      expect { described_class.new(invalid_xml) }.not_to raise_error
    end
  end

  describe 'NodeHelper methods' do
    let(:document) { described_class.new(simple_xml) }

    describe '#at_xpath' do
      it 'finds a single node by xpath' do
        node = document.at_xpath("//#{Ubl2Cii::PREFIX_CBC}:ID")
        expect(node).to be_a(Nokogiri::XML::Element)
        expect(node.text).to eq('INVOICE-001')
      end

      it 'returns nil for non-existing path' do
        node = document.at_xpath("//#{Ubl2Cii::PREFIX_CBC}:NonExistingElement")
        expect(node).to be_nil
      end

      it 'returns nil when node is nil' do
        doc = described_class.allocate
        doc.instance_variable_set(:@node, nil)
        doc.instance_variable_set(:@namespaces, {})

        expect(doc.at_xpath("//#{Ubl2Cii::PREFIX_CBC}:ID")).to be_nil
      end

      it 'uses provided namespaces' do
        expect(document.at_xpath("//#{Ubl2Cii::PREFIX_CBC}:ID")).not_to be_nil
      end
    end

    describe '#xpath' do
      it 'finds multiple nodes by xpath' do
        nodes = document.xpath("//#{Ubl2Cii::PREFIX_CAC}:InvoiceLine", multiple: true)
        expect(nodes.size).to eq(2)
        expect(nodes).to all(be_a(Nokogiri::XML::Element))
      end

      it 'returns empty NodeSet for non-existing path' do
        nodes = document.xpath("//#{Ubl2Cii::PREFIX_CBC}:NonExistingElement", multiple: true)
        expect(nodes).to be_empty
      end

      it 'uses provided namespaces' do
        expect(document.xpath("//#{Ubl2Cii::PREFIX_CAC}:InvoiceLine", multiple: true).size).to eq(2)
      end
    end

    describe '#content_at' do
      it 'returns content of the node at xpath' do
        expect(document.content_at("//#{Ubl2Cii::PREFIX_CBC}:ID")).to eq('INVOICE-001')
        expect(document.content_at("//#{Ubl2Cii::PREFIX_CBC}:IssueDate")).to eq('2025-04-13')
      end

      it 'returns nil for non-existing path' do
        expect(document.content_at("//#{Ubl2Cii::PREFIX_CBC}:NonExistingElement")).to be_nil
      end

      it 'safely handles nil nodes' do
        expect(document.content_at("//#{Ubl2Cii::PREFIX_CBC}:NonExistingElement/Child")).to be_nil
      end
    end

    describe '#attribute_at' do
      it 'returns attribute value of the node at xpath' do
        expect(document.attribute_at("//#{Ubl2Cii::PREFIX_CBC}:EndpointID", 'schemeID')).to eq('0088')
        expect(document.attribute_at("//#{Ubl2Cii::PREFIX_CBC}:LineExtensionAmount", 'currencyID')).to eq('EUR')
      end

      it 'returns nil for non-existing attribute' do
        expect(document.attribute_at("//#{Ubl2Cii::PREFIX_CBC}:ID", 'nonExisting')).to be_nil
      end

      it 'returns nil for non-existing path' do
        expect(document.attribute_at("//#{Ubl2Cii::PREFIX_CBC}:NonExistingElement", 'schemeID')).to be_nil
      end

      it 'safely handles nil nodes' do
        expect(document.attribute_at("//#{Ubl2Cii::PREFIX_CBC}:NonExistingElement/Child", 'attr')).to be_nil
      end
    end

    describe '#map_nodes' do
      it 'maps nodes to objects' do
        lines = document.map_nodes("//#{Ubl2Cii::PREFIX_CAC}:InvoiceLine") do |node|
          described_class.new_from_node(node, document.namespaces)
        end
        expect(lines.size).to eq(2)
        expect(lines).to all(be_a(described_class))
        expect(lines.first.content_at(".//#{Ubl2Cii::PREFIX_CBC}:ID")).to eq('1')
        expect(lines.last.content_at(".//#{Ubl2Cii::PREFIX_CBC}:ID")).to eq('2')
      end

      it 'returns empty array for non-existing path' do
        lines = document.map_nodes("//#{Ubl2Cii::PREFIX_CAC}:NonExistingElement") do |node|
          described_class.new_from_node(node, document.namespaces)
        end
        expect(lines).to be_empty
      end
    end
  end
end
