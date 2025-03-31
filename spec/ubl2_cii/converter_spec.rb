# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'

describe Ubl2Cii::Converter do
  # Define XML namespaces for XPath queries
  let(:namespaces) do
    {
      'rsm' => 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100',
      'ram' => 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100',
      'udt' => 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100',
      'qdt' => 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100'
    }
  end

  let(:converter) { described_class.new(ubl_xml) }
  let(:cii_xml) { converter.convert_to_cii }
  let(:cii_doc) { Nokogiri::XML(cii_xml, nil, 'UTF-8') }

  # Helper method to find value by XPath
  def find_value(xpath, doc=cii_doc)
    doc.xpath(xpath, namespaces)&.inner_text
  end

  # Template helper for UBL XML
  def ubl_template
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
             xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
             xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2">
        <cbc:ID>TOSL108</cbc:ID>
        #{yield if block_given?}
      </Invoice>
    XML
  end

  describe '#convert_to_cii' do
    context 'root structure' do
      let(:ubl_xml) { ubl_template }

      it 'creates a CrossIndustryInvoice root element' do
        expect(cii_doc.root.name).to eq('CrossIndustryInvoice')
        expect(cii_doc.root.namespace.href).to eq(namespaces['rsm'])
      end

      it 'includes all required namespaces' do
        expect(cii_doc.namespaces['xmlns:rsm']).to eq(namespaces['rsm'])
        expect(cii_doc.namespaces['xmlns:ram']).to eq(namespaces['ram'])
        expect(cii_doc.namespaces['xmlns:udt']).to eq(namespaces['udt'])
        expect(cii_doc.namespaces['xmlns:qdt']).to eq(namespaces['qdt'])
      end
    end

    context 'ExchangedDocument section' do
      let(:ubl_xml) do
        ubl_template do
          <<~CONTENT
            <cbc:IssueDate>2009-12-15</cbc:IssueDate>
            <cbc:InvoiceTypeCode>380</cbc:InvoiceTypeCode>
            <cbc:Note>Ordered in our booth at the convention.</cbc:Note>
          CONTENT
        end
      end

      it 'maps invoice ID' do
        expect(find_value('//rsm:ExchangedDocument/ram:ID')).to eq('TOSL108')
      end

      it 'maps invoice issue date' do
        date_element = cii_doc.xpath('//rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString', namespaces).first
        expect(date_element.text).to eq('20091215')
        expect(date_element['format']).to eq('102')
      end

      it 'maps invoice type code' do
        expect(find_value('//rsm:ExchangedDocument/ram:TypeCode')).to eq('380')
      end

      it 'maps invoice note' do
        expect(find_value('//rsm:ExchangedDocument/ram:IncludedNote/ram:Content')).to eq('Ordered in our booth at the convention.')
      end
    end

    context 'HeaderTradeSettlement section' do
      context 'basic settlement information' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
              <cbc:AccountingCost>Project cost code 123</cbc:AccountingCost>
            CONTENT
          end
        end

        it 'maps invoice currency code' do
          expect(find_value('//ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode')).to eq('EUR')
        end

        it 'maps accounting cost' do
          expect(find_value('//ram:ApplicableHeaderTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount/ram:ID')).to eq('Project cost code 123')
        end
      end

      context 'BillingSpecifiedPeriod' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:InvoicePeriod>
                <cbc:StartDate>2009-11-01</cbc:StartDate>
                <cbc:EndDate>2009-11-30</cbc:EndDate>
              </cac:InvoicePeriod>
            CONTENT
          end
        end

        it 'maps invoice period start date' do
          date_element = cii_doc.xpath(
            '//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString', namespaces
          ).first
          expect(date_element.text).to eq('20091101')
          expect(date_element['format']).to eq('102')
        end

        it 'maps invoice period end date' do
          date_element = cii_doc.xpath(
            '//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString', namespaces
          ).first
          expect(date_element.text).to eq('20091130')
          expect(date_element['format']).to eq('102')
        end
      end

      context 'TradeTax section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:TaxTotal>
                <cbc:TaxAmount currencyID="EUR">25.00</cbc:TaxAmount>
                <cac:TaxSubtotal>
                  <cbc:TaxableAmount currencyID="EUR">100.00</cbc:TaxableAmount>
                  <cbc:TaxAmount currencyID="EUR">25.00</cbc:TaxAmount>
                  <cac:TaxCategory>
                    <cbc:ID>S</cbc:ID>
                    <cbc:Percent>25.00</cbc:Percent>
                    <cac:TaxScheme>
                      <cbc:ID>VAT</cbc:ID>
                    </cac:TaxScheme>
                  </cac:TaxCategory>
                </cac:TaxSubtotal>
              </cac:TaxTotal>
            CONTENT
          end
        end

        it 'maps tax total amount' do
          tax_total = find_value('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount')
          expect(tax_total).to eq('25.00')
        end

        it 'maps tax basis amount' do
          basis_amount = find_value('//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:BasisAmount')
          expect(basis_amount).to eq('100.00')
        end

        it 'maps tax percentage' do
          rate = find_value('//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent')
          expect(rate).to eq('25.00')
        end
      end

      context 'TradeSettlementHeaderMonetarySummation section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:LegalMonetaryTotal>
                <cbc:LineExtensionAmount currencyID="EUR">100.00</cbc:LineExtensionAmount>
                <cbc:TaxExclusiveAmount currencyID="EUR">100.00</cbc:TaxExclusiveAmount>
                <cbc:TaxInclusiveAmount currencyID="EUR">125.00</cbc:TaxInclusiveAmount>
                <cbc:PayableAmount currencyID="EUR">125.00</cbc:PayableAmount>
              </cac:LegalMonetaryTotal>
            CONTENT
          end
        end

        it 'maps line extension amount' do
          amount = find_value('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount')
          expect(amount).to eq('100.00')
        end

        it 'maps tax basis total amount' do
          amount = find_value('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount')
          expect(amount).to eq('100.00')
        end

        it 'maps grand total amount' do
          amount = find_value('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount')
          expect(amount).to eq('125.00')
        end

        it 'maps due payable amount' do
          amount = find_value('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount')
          expect(amount).to eq('125.00')
        end
      end

      context 'PaymentMeans section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:PaymentMeans>
                <cbc:PaymentMeansCode>30</cbc:PaymentMeansCode>
                <cbc:PaymentID>REF-123456</cbc:PaymentID>
                <cac:PayeeFinancialAccount>
                  <cbc:ID>DE12345678901234567890</cbc:ID>
                  <cbc:Name>Business Account</cbc:Name>
                </cac:PayeeFinancialAccount>
              </cac:PaymentMeans>
            CONTENT
          end
        end

        let(:payment_path) { '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans' }

        it 'maps payment means type code' do
          code = find_value("#{payment_path}/ram:TypeCode")
          expect(code).to eq('30')
        end

        it 'maps payment reference' do
          ref = find_value('//ram:ApplicableHeaderTradeSettlement/ram:PaymentReference')
          expect(ref).to eq('REF-123456')
        end

        context 'CreditorFinancialAccount section' do
          it 'maps IBAN ID' do
            iban = find_value("#{payment_path}/ram:PayeePartyCreditorFinancialAccount/ram:IBANID")
            expect(iban).to eq('DE12345678901234567890')
          end

          it 'maps account name' do
            name = find_value("#{payment_path}/ram:PayeePartyCreditorFinancialAccount/ram:AccountName")
            expect(name).to eq('Business Account')
          end
        end
      end

      context 'TradePaymentTerms section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:PaymentTerms>
                <cbc:Note>30 days net</cbc:Note>
              </cac:PaymentTerms>
              <cac:PaymentMeans>
                <cbc:PaymentDueDate>2010-01-14</cbc:PaymentDueDate>
              </cac:PaymentMeans>
            CONTENT
          end
        end

        it 'maps payment terms description' do
          desc = find_value('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:Description')
          expect(desc).to eq('30 days net')
        end

        it 'maps due date' do
          date_element = cii_doc.xpath(
            '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:DueDateDateTime/udt:DateTimeString', namespaces
          )
          expect(date_element.text).to eq('20100114')
          expect(date_element.attr('format').value).to eq('102')
        end
      end

      context 'TradeAllowanceCharge section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:AllowanceCharge>
                <cbc:ChargeIndicator>true</cbc:ChargeIndicator>
                <cbc:AllowanceChargeReason>Transport charge</cbc:AllowanceChargeReason>
                <cbc:Amount currencyID="EUR">10.00</cbc:Amount>
              </cac:AllowanceCharge>
              <cac:AllowanceCharge>
                <cbc:ChargeIndicator>false</cbc:ChargeIndicator>
                <cbc:AllowanceChargeReason>Discount</cbc:AllowanceChargeReason>
                <cbc:Amount currencyID="EUR">5.00</cbc:Amount>
              </cac:AllowanceCharge>
            CONTENT
          end
        end

        let(:allowance_charges) {
          cii_doc.xpath('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge', namespaces)
        }

        it 'maps charge indicator correctly' do
          expect(allowance_charges.count).to eq(2)

          charge_indicator = allowance_charges[0].xpath('./ram:ChargeIndicator/udt:Indicator', namespaces).text
          expect(charge_indicator).to eq('true')

          allowance_indicator = allowance_charges[1].xpath('./ram:ChargeIndicator/udt:Indicator', namespaces).text
          expect(allowance_indicator).to eq('false')
        end

        it 'maps allowance/charge reason' do
          charge_reason = allowance_charges[0].xpath('./ram:Reason', namespaces).text
          expect(charge_reason).to eq('Transport charge')

          allowance_reason = allowance_charges[1].xpath('./ram:Reason', namespaces).text
          expect(allowance_reason).to eq('Discount')
        end

        it 'maps allowance/charge amount' do
          charge_amount = allowance_charges[0].xpath('./ram:ActualAmount', namespaces).text
          expect(charge_amount).to eq('10.00')

          allowance_amount = allowance_charges[1].xpath('./ram:ActualAmount', namespaces).text
          expect(allowance_amount).to eq('5.00')
        end
      end
    end

    context 'HeaderTradeAgreement section' do
      context 'DocumentReferences' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:OrderReference>
                <cbc:ID>123</cbc:ID>
              </cac:OrderReference>
              <cac:ContractDocumentReference>
                <cbc:ID>Contract321</cbc:ID>
              </cac:ContractDocumentReference>
              <cac:AdditionalDocumentReference>
                <cbc:ID>Doc1</cbc:ID>
                <cac:Attachment>
                  <cac:ExternalReference>
                    <cbc:URI>http://example.com/docs/doc1.pdf</cbc:URI>
                  </cac:ExternalReference>
                </cac:Attachment>
              </cac:AdditionalDocumentReference>
              <cac:AdditionalDocumentReference>
                <cbc:ID>Doc2</cbc:ID>
              </cac:AdditionalDocumentReference>
            CONTENT
          end
        end

        it 'maps order reference ID' do
          expect(find_value('//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID')).to eq('123')
        end

        it 'maps contract reference ID' do
          expect(find_value('//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID')).to eq('Contract321')
        end

        context 'AdditionalReferencedDocument' do
          it 'maps multiple additional document IDs' do
            additional_docs = cii_doc.xpath('//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument',
                                            namespaces)
            expect(additional_docs.length).to eq(2)
            expect(additional_docs[0].xpath('./ram:IssuerAssignedID', namespaces).text).to eq('Doc1')
            expect(additional_docs[1].xpath('./ram:IssuerAssignedID', namespaces).text).to eq('Doc2')
          end

          it 'maps document URI' do
            uri = cii_doc.xpath('//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument/ram:URIID',
                                namespaces)
            expect(uri.text).to eq('http://example.com/docs/doc1.pdf')
          end
        end
      end

      context 'SellerTradeParty section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:AccountingSupplierParty>
                <cac:Party>
                  <cbc:EndpointID schemeID="0088">7300010000001</cbc:EndpointID>
                  <cac:PartyIdentification>
                    <cbc:ID schemeID="0088">7300010000001</cbc:ID>
                  </cac:PartyIdentification>
                  <cac:PartyName>
                    <cbc:Name>The Seller Company</cbc:Name>
                  </cac:PartyName>
                  <cac:PostalAddress>
                    <cbc:StreetName>Main Street 1</cbc:StreetName>
                    <cbc:AdditionalStreetName>Building A</cbc:AdditionalStreetName>
                    <cbc:CityName>Big City</cbc:CityName>
                    <cbc:PostalZone>12345</cbc:PostalZone>
                    <cbc:CountrySubentity>Region</cbc:CountrySubentity>
                    <cac:Country>
                      <cbc:IdentificationCode>DE</cbc:IdentificationCode>
                    </cac:Country>
                  </cac:PostalAddress>
                  <cac:PartyTaxScheme>
                    <cbc:CompanyID>DE123456789</cbc:CompanyID>
                    <cac:TaxScheme>
                      <cbc:ID>VAT</cbc:ID>
                    </cac:TaxScheme>
                  </cac:PartyTaxScheme>
                  <cac:PartyLegalEntity>
                    <cbc:RegistrationName>The Seller Legal Name</cbc:RegistrationName>
                    <cbc:CompanyID schemeID="0088">7300010000001</cbc:CompanyID>
                  </cac:PartyLegalEntity>
                </cac:Party>
              </cac:AccountingSupplierParty>
            CONTENT
          end
        end

        let(:seller_path) { '//ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty' }

        it 'maps seller name' do
          expect(find_value("#{seller_path}/ram:Name")).to eq('The Seller Company')
        end

        it 'maps seller ID with scheme' do
          id_node = cii_doc.xpath("#{seller_path}/ram:ID", namespaces).first
          expect(id_node.text).to eq('7300010000001')
          expect(id_node['schemeID']).to eq('0088')
        end

        context 'PostalTradeAddress' do
          let(:address_path) { "#{seller_path}/ram:PostalTradeAddress" }

          it 'maps seller street name' do
            expect(find_value("#{address_path}/ram:LineOne")).to eq('Main Street 1')
            expect(find_value("#{address_path}/ram:LineTwo")).to eq('Building A')
          end

          it 'maps seller city name' do
            expect(find_value("#{address_path}/ram:CityName")).to eq('Big City')
          end

          it 'maps seller postal code' do
            expect(find_value("#{address_path}/ram:PostcodeCode")).to eq('12345')
          end

          it 'maps seller country ID' do
            expect(find_value("#{address_path}/ram:CountryID")).to eq('DE')
          end

          it 'maps seller country subdivision' do
            expect(find_value("#{address_path}/ram:CountrySubDivisionName")).to eq('Region')
          end
        end

        context 'SpecifiedTaxRegistration' do
          it 'maps seller tax ID' do
            tax_id = cii_doc.xpath("#{seller_path}/ram:SpecifiedTaxRegistration/ram:ID", namespaces).first
            expect(tax_id.text).to eq('DE123456789')
            expect(tax_id['schemeID']).to eq('VAT')
          end
        end

        context 'SpecifiedLegalOrganization' do
          it 'maps seller trading name' do
            expect(find_value("#{seller_path}/ram:SpecifiedLegalOrganization/ram:TradingBusinessName")).to eq('The Seller Legal Name')
          end

          it 'maps company ID' do
            company_id = cii_doc.xpath("#{seller_path}/ram:SpecifiedLegalOrganization/ram:ID", namespaces).first
            expect(company_id.text).to eq('7300010000001')
            expect(company_id['schemeID']).to eq('0088')
          end
        end
      end

      context 'BuyerTradeParty section' do
        let(:ubl_xml) do
          ubl_template do
            <<~CONTENT
              <cac:AccountingCustomerParty>
                <cac:Party>
                  <cbc:EndpointID schemeID="0088">7300010000002</cbc:EndpointID>
                  <cac:PartyIdentification>
                    <cbc:ID schemeID="0088">7300010000002</cbc:ID>
                  </cac:PartyIdentification>
                  <cac:PartyName>
                    <cbc:Name>The Buyer Company</cbc:Name>
                  </cac:PartyName>
                  <cac:PostalAddress>
                    <cbc:StreetName>Main Buyer Street 1</cbc:StreetName>
                    <cbc:AdditionalStreetName>Building B</cbc:AdditionalStreetName>
                    <cbc:CityName>Buyer City</cbc:CityName>
                    <cbc:PostalZone>54321</cbc:PostalZone>
                    <cbc:CountrySubentity>Buyer Region</cbc:CountrySubentity>
                    <cac:Country>
                      <cbc:IdentificationCode>FR</cbc:IdentificationCode>
                    </cac:Country>
                  </cac:PostalAddress>
                  <cac:PartyLegalEntity>
                    <cbc:RegistrationName>The Buyer Legal Name</cbc:RegistrationName>
                    <cbc:CompanyID schemeID="0088">7300010000002</cbc:CompanyID>
                  </cac:PartyLegalEntity>
                </cac:Party>
              </cac:AccountingCustomerParty>
            CONTENT
          end
        end

        let(:buyer_path) { '//ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty' }

        it 'maps buyer name' do
          expect(find_value("#{buyer_path}/ram:Name")).to eq('The Buyer Company')
        end

        it 'maps buyer ID with scheme' do
          id_node = cii_doc.xpath("#{buyer_path}/ram:ID", namespaces).first
          expect(id_node.text).to eq('7300010000002')
          expect(id_node['schemeID']).to eq('0088')
        end

        context 'PostalTradeAddress' do
          let(:address_path) { "#{buyer_path}/ram:PostalTradeAddress" }

          it 'maps buyer street name' do
            expect(find_value("#{address_path}/ram:LineOne")).to eq('Main Buyer Street 1')
            expect(find_value("#{address_path}/ram:LineTwo")).to eq('Building B')
          end

          it 'maps buyer city name' do
            expect(find_value("#{address_path}/ram:CityName")).to eq('Buyer City')
          end

          it 'maps buyer postal code' do
            expect(find_value("#{address_path}/ram:PostcodeCode")).to eq('54321')
          end

          it 'maps buyer country ID' do
            expect(find_value("#{address_path}/ram:CountryID")).to eq('FR')
          end

          it 'maps buyer country subdivision' do
            expect(find_value("#{address_path}/ram:CountrySubDivisionName")).to eq('Buyer Region')
          end
        end
      end
    end

    context 'HeaderTradeDelivery section' do
      let(:ubl_xml) do
        ubl_template do
          <<~CONTENT
            <cac:Delivery>
              <cbc:ActualDeliveryDate>2009-12-01</cbc:ActualDeliveryDate>
              <cac:DeliveryLocation>
                <cbc:ID schemeID="0088">7300010000003</cbc:ID>
                <cac:Address>
                  <cbc:StreetName>Delivery Street 1</cbc:StreetName>
                  <cbc:AdditionalStreetName>Building C</cbc:AdditionalStreetName>
                  <cbc:CityName>Delivery City</cbc:CityName>
                  <cbc:PostalZone>98765</cbc:PostalZone>
                  <cbc:CountrySubentity>Delivery Region</cbc:CountrySubentity>
                  <cac:Country>
                    <cbc:IdentificationCode>BE</cbc:IdentificationCode>
                  </cac:Country>
                </cac:Address>
              </cac:DeliveryLocation>
            </cac:Delivery>
          CONTENT
        end
      end

      it 'maps actual delivery date' do
        date_element = cii_doc.xpath(
          '//ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString', namespaces
        )
        expect(date_element.text).to eq('20091201')
        expect(date_element.attr('format').value).to eq('102')
      end

      context 'ShipToTradeParty section' do
        let(:location_path) { '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty' }

        it 'maps delivery location ID with scheme' do
          id_node = cii_doc.xpath("#{location_path}/ram:ID", namespaces).first
          expect(id_node.text).to eq('7300010000003')
          expect(id_node['schemeID']).to eq('0088')
        end

        context 'PostalTradeAddress' do
          let(:address_path) { "#{location_path}/ram:PostalTradeAddress" }

          it 'maps delivery location address details' do
            expect(find_value("#{address_path}/ram:LineOne")).to eq('Delivery Street 1')
            expect(find_value("#{address_path}/ram:LineTwo")).to eq('Building C')
            expect(find_value("#{address_path}/ram:CityName")).to eq('Delivery City')
            expect(find_value("#{address_path}/ram:PostcodeCode")).to eq('98765')
            expect(find_value("#{address_path}/ram:CountryID")).to eq('BE')
            expect(find_value("#{address_path}/ram:CountrySubDivisionName")).to eq('Delivery Region')
          end
        end
      end
    end

    context 'IncludedSupplyChainTradeLineItem section' do
      let(:ubl_xml) do
        ubl_template do
          <<~CONTENT
            <cbc:DocumentCurrencyCode>EUR</cbc:DocumentCurrencyCode>
            <cac:InvoiceLine>
              <cbc:ID>1</cbc:ID>
              <cbc:Note>Line note 1</cbc:Note>
              <cbc:InvoicedQuantity unitCode="EA">10</cbc:InvoicedQuantity>
              <cbc:LineExtensionAmount currencyID="EUR">100.00</cbc:LineExtensionAmount>
              <cac:OrderLineReference>
                <cbc:LineID>Order-line-1</cbc:LineID>
              </cac:OrderLineReference>
              <cac:Item>
                <cbc:Name>Item 1</cbc:Name>
                <cbc:Description>Item 1 description</cbc:Description>
                <cac:SellersItemIdentification>
                  <cbc:ID>SELLER-ITEM-1</cbc:ID>
                </cac:SellersItemIdentification>
                <cac:StandardItemIdentification>
                  <cbc:ID schemeID="0160">1234567890123</cbc:ID>
                </cac:StandardItemIdentification>
                <cac:ClassifiedTaxCategory>
                  <cbc:ID>S</cbc:ID>
                  <cbc:Percent>21</cbc:Percent>
                  <cac:TaxScheme>
                    <cbc:ID>VAT</cbc:ID>
                  </cac:TaxScheme>
                </cac:ClassifiedTaxCategory>
                <cac:AdditionalItemProperty>
                  <cbc:Name>Color</cbc:Name>
                  <cbc:Value>Blue</cbc:Value>
                </cac:AdditionalItemProperty>
                <cac:AdditionalItemProperty>
                  <cbc:Name>Size</cbc:Name>
                  <cbc:Value>Large</cbc:Value>
                </cac:AdditionalItemProperty>
              </cac:Item>
              <cac:Price>
                <cbc:PriceAmount currencyID="EUR">10.00</cbc:PriceAmount>
              </cac:Price>
            </cac:InvoiceLine>
            <cac:InvoiceLine>
              <cbc:ID>2</cbc:ID>
              <cbc:InvoicedQuantity unitCode="EA">5</cbc:InvoicedQuantity>
              <cbc:LineExtensionAmount currencyID="EUR">50.00</cbc:LineExtensionAmount>
              <cac:Item>
                <cbc:Name>Item 2</cbc:Name>
              </cac:Item>
              <cac:Price>
                <cbc:PriceAmount currencyID="EUR">10.00</cbc:PriceAmount>
              </cac:Price>
            </cac:InvoiceLine>
          CONTENT
        end
      end

      let(:line_items) { cii_doc.xpath('//ram:IncludedSupplyChainTradeLineItem', namespaces) }

      it 'maps all line items' do
        expect(line_items.length).to eq(2)
      end

      context 'basic line item information' do
        let(:line_item) { line_items.first }

        it 'maps line ID' do
          expect(line_item.xpath('./ram:AssociatedDocumentLineDocument/ram:LineID', namespaces).text).to eq('1')
        end

        it 'maps line note' do
          expect(line_item.xpath('./ram:AssociatedDocumentLineDocument/ram:IncludedNote/ram:Content',
                                 namespaces).text).to eq('Line note 1')
        end

        it 'maps billed quantity with unit code' do
          qty = line_item.xpath('./ram:SpecifiedLineTradeDelivery/ram:BilledQuantity', namespaces)
          expect(qty.text).to eq('10')
          expect(qty.attr('unitCode').value).to eq('EA')
        end

        it 'maps line total amount' do
          amount = line_item.xpath(
            './ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount', namespaces
          )
          expect(amount.text).to eq('100.00')
          expect(amount.attr('currencyID').value).to eq('EUR')
        end
      end

      context 'SpecifiedTradeProduct section' do
        let(:line_item) { line_items.first }
        let(:product_path) { './ram:SpecifiedTradeProduct' }

        it 'maps product name' do
          expect(line_item.xpath("#{product_path}/ram:Name", namespaces).text).to eq('Item 1')
        end

        it 'maps product description' do
          expect(line_item.xpath("#{product_path}/ram:Description", namespaces).text).to eq('Item 1 description')
        end

        it 'maps seller assigned ID' do
          expect(line_item.xpath("#{product_path}/ram:SellerAssignedID", namespaces).text).to eq('SELLER-ITEM-1')
        end

        it 'maps global ID with scheme' do
          global_id = line_item.xpath("#{product_path}/ram:GlobalID", namespaces)
          expect(global_id.text).to eq('1234567890123')
          expect(global_id.attr('schemeID').value).to eq('0160')
        end

        it 'maps additional item properties' do
          props = line_item.xpath("#{product_path}/ram:ApplicableProductCharacteristic", namespaces)
          expect(props.length).to eq(2)

          expect(props[0].xpath('./ram:Description', namespaces).text).to eq('Color')
          expect(props[0].xpath('./ram:Value', namespaces).text).to eq('Blue')

          expect(props[1].xpath('./ram:Description', namespaces).text).to eq('Size')
          expect(props[1].xpath('./ram:Value', namespaces).text).to eq('Large')
        end
      end

      context 'ApplicableTradeTax section' do
        let(:line_item) { line_items.first }
        let(:tax_path) { './ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax' }

        it 'maps tax category code' do
          expect(line_item.xpath("#{tax_path}/ram:CategoryCode", namespaces).text).to eq('S')
        end

        it 'maps tax rate percentage' do
          expect(line_item.xpath("#{tax_path}/ram:RateApplicablePercent", namespaces).text).to eq('21')
        end
      end

      context 'BuyerOrderReferencedDocument section' do
        let(:line_item) { line_items.first }

        it 'maps order line reference ID' do
          line_ref = line_item.xpath('./ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID',
                                     namespaces)
          expect(line_ref.text).to eq('Order-line-1')
        end
      end
    end

    context 'PayeeTradeParty section' do
      let(:ubl_xml) do
        ubl_template do
          <<~CONTENT
            <cac:PayeeParty>
              <cac:PartyIdentification>
                <cbc:ID schemeID="0088">7300010000004</cbc:ID>
              </cac:PartyIdentification>
              <cac:PartyName>
                <cbc:Name>Payee Company</cbc:Name>
              </cac:PartyName>
              <cac:PartyLegalEntity>
                <cbc:CompanyID schemeID="0088">7300010000004</cbc:CompanyID>
              </cac:PartyLegalEntity>
            </cac:PayeeParty>
          CONTENT
        end
      end

      let(:payee_path) { '//ram:ApplicableHeaderTradeAgreement/ram:PayeeTradeParty' }

      it 'maps payee name' do
        expect(find_value("#{payee_path}/ram:Name")).to eq('Payee Company')
      end

      it 'maps payee ID with scheme' do
        id_node = cii_doc.xpath("#{payee_path}/ram:ID", namespaces).first
        expect(id_node.text).to eq('7300010000004')
        expect(id_node['schemeID']).to eq('0088')
      end

      it 'maps payee company ID' do
        id_node = cii_doc.xpath("#{payee_path}/ram:SpecifiedLegalOrganization/ram:ID", namespaces).first
        expect(id_node.text).to eq('7300010000004')
        expect(id_node['schemeID']).to eq('0088')
      end
    end

    context 'SellerTaxRepresentativeTradeParty section' do
      let(:ubl_xml) do
        ubl_template do
          <<~CONTENT
            <cac:TaxRepresentativeParty>
              <cac:PartyName>
                <cbc:Name>Tax Rep Company</cbc:Name>
              </cac:PartyName>
              <cac:PartyTaxScheme>
                <cbc:CompanyID>FR999999999</cbc:CompanyID>
                <cac:TaxScheme>
                  <cbc:ID>VAT</cbc:ID>
                </cac:TaxScheme>
              </cac:PartyTaxScheme>
            </cac:TaxRepresentativeParty>
          CONTENT
        end
      end

      let(:tax_rep_path) { '//ram:ApplicableHeaderTradeAgreement/ram:SellerTaxRepresentativeTradeParty' }

      it 'maps tax representative name' do
        expect(find_value("#{tax_rep_path}/ram:Name")).to eq('Tax Rep Company')
      end

      it 'maps tax representative ID' do
        tax_id = cii_doc.xpath("#{tax_rep_path}/ram:SpecifiedTaxRegistration/ram:ID", namespaces).first
        expect(tax_id.text).to eq('FR999999999')
        expect(tax_id['schemeID']).to eq('VAT')
      end
    end
  end
end
