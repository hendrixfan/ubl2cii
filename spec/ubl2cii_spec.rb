# frozen_string_literal: true

require 'spec_helper'

describe Ubl2Cii do
  let(:ubl_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
        <ID>INVOICE-001</ID>
      </Invoice>
    XML
  end

  it "has a version number" do
    expect(Ubl2Cii::VERSION).not_to be nil
  end

  describe "Converter" do
    subject(:converter) { Ubl2Cii::Converter.new(ubl_xml) }

    describe "#convert_to_cii" do
      let(:cii_xml) { converter.convert_to_cii }

      it "converts UBL to CII format" do
        expect(cii_xml).to include('xmlns:ram="urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100"')
        expect(cii_xml).to include('xmlns:udt="urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100"')
        expect(cii_xml).to include('xmlns:qdt="urn:un:unece:uncefact:data:standard:QualifiedDataType:100"')
        expect(cii_xml).to include('xmlns:rsm="urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100"')
        expect(cii_xml).to include("<ID>INVOICE-001</ID>")
      end

      context "with additional elements" do
        let(:ubl_xml) do
          <<~XML
            <?xml version="1.0" encoding="UTF-8"?>
            <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
                     xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
                     xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">
              <cbc:ID>INVOICE-002</cbc:ID>
              <cbc:IssueDate>2023-01-01</cbc:IssueDate>
              <cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
              <cbc:Note>Test note</cbc:Note>
            </Invoice>
          XML
        end

        it "maps additional elements correctly" do
          expect(cii_xml).to include("<ram:ID>INVOICE-002</ram:ID>")
          expect(cii_xml).to include("<ram:TypeCode>380</ram:TypeCode>")
          expect(cii_xml).to include("<ram:IssueDateTime><udt:DateTimeString format=\"102\">20230101</udt:DateTimeString></ram:IssueDateTime>")
          expect(cii_xml).to include("<ram:IncludedNote><ram:Content>Test note</ram:Content></ram:IncludedNote>")
        end
      end
    end
  end
end
