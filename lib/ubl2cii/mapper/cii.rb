# frozen_string_literal: true

module Ubl2Cii
  module Mapper
    class Cii < Dsl
      element 'ExchangedDocumentContext', prefix: PREFIX_RSM do
        element 'GuidelineSpecifiedDocumentContextParameter', prefix: PREFIX_RAM do
          element 'ID', source: '//cbc:CustomizationID', prefix: PREFIX_RAM
        end
      end

      element 'ExchangedDocument', prefix: PREFIX_RSM do
        element 'ID', source: '//cbc:ID', prefix: PREFIX_RAM
        element 'TypeCode', source: '//cbc:InvoiceTypeCode', prefix: PREFIX_RAM
        element 'IssueDateTime', prefix: PREFIX_RAM do
          element 'DateTimeString', source: '//cbc:IssueDate', properties: {format: '102'}, prefix: PREFIX_UDT
        end
        element 'IncludedNote', prefix: PREFIX_RAM do
          element 'Content', source: '//cbc:Note'
        end
      end

      element 'SupplyChainTradeTransaction', prefix: PREFIX_RSM do
        collection 'IncludedSupplyChainTradeLineItem', source: '//cac:InvoiceLine', prefix: PREFIX_RAM do
          element 'AssociatedDocumentLineDocument' do
            element 'LineID', source: 'cbc:ID'
            element 'IncludedNote', prefix: PREFIX_RAM do
              element 'Content', source: 'cbc:Note'
            end
          end

          element 'SpecifiedTradeProduct', source: 'cac:Item' do
            element 'GlobalID', source: 'cac:StandardItemIdentification//cbc:ID', source_properties: [:schemeID]
            element 'SellerAssignedID', source: 'cac:SellersItemIdentification//cbc:ID'
            element 'Name', source: 'cbc:Name'
            element 'Description', source: 'cbc:Description'
            collection 'ApplicableProductCharacteristic', source: 'cac:AdditionalItemProperty', prefix: PREFIX_RAM do
              element 'Description', source: 'cbc:Name'
              element 'Value', source: 'cbc:Value'
            end

            collection 'DesignatedProductClassification', source: 'cac:CommodityClassification', prefix: PREFIX_RAM do
              element 'ClassCode', source: 'cbc:ItemClassificationCode', source_properties: [:listID]
            end
          end

          element 'SpecifiedLineTradeAgreement' do
            element 'BuyerOrderReferencedDocument' do
              element 'LineID', source: 'cac:OrderLineReference//cbc:LineID'
            end
            element 'NetPriceProductTradePrice' do
              element 'ChargeAmount', source: 'cac:Price//cbc:PriceAmount', source_properties: [:currencyID]
            end
          end

          element 'SpecifiedLineTradeDelivery' do
            element 'BilledQuantity', source: 'cbc:InvoicedQuantity', source_properties: [:unitCode]
          end

          element 'SpecifiedLineTradeSettlement' do
            element 'ApplicableTradeTax', source: 'cac:Item//cac:ClassifiedTaxCategory' do
              element 'TypeCode', source: 'cac:TaxScheme//cbc:ID'
              element 'CategoryCode', source: 'cbc:ID'
              element 'RateApplicablePercent', source: 'cbc:Percent'
            end
            element 'SpecifiedTradeSettlementLineMonetarySummation' do
              element 'LineTotalAmount', source: 'cbc:LineExtensionAmount', source_properties: [:currencyID]
            end
            element 'ReceivableSpecifiedTradeAccountingAccount' do
              element 'ID', source: 'cbc:AccountingCost'
            end
          end
        end
        element 'ApplicableHeaderTradeAgreement', prefix: PREFIX_RAM do
          element 'SellerTradeParty', source: '//cac:AccountingSupplierParty//cac:Party' do
            element 'ID', source: 'cac:PartyIdentification//cbc:ID', source_properties: [:schemeID]
            element 'Name', source: 'cac:PartyName//cbc:Name'
            element 'SpecifiedLegalOrganization', source: 'cac:PartyLegalEntity' do
              element 'ID', source: 'cbc:CompanyID', source_properties: [:schemeID]
              element 'TradingBusinessName', source: 'cbc:RegistrationName'
              element 'PostalTradeAddress', source: 'cac:RegistrationAddress' do
                element 'CityName', source: 'cbc:CityName'
                element 'CountryID', source: 'cac:Country//cbc:IdentificationCode'
                element 'CountrySubDivisionName', source: 'cbc:CountrySubentity'
              end
            end
            element 'PostalTradeAddress', source: 'cac:PostalAddress' do
              element 'PostcodeCode', source: 'cbc:PostalZone'
              element 'LineOne', source: 'cbc:StreetName'
              element 'LineTwo', source: 'cbc:AdditionalStreetName'
              element 'CityName', source: 'cbc:CityName'
              element 'CountryID', source: 'cac:Country//cbc:IdentificationCode'
              element 'CountrySubDivisionName', source: 'cbc:CountrySubentity'
            end
            element 'URIUniversalCommunication' do
              element 'URIID', source: 'cbc:EndpointID', source_properties: [:schemeID]
            end

            element 'SpecifiedTaxRegistration', source: 'cac:PartyTaxScheme' do
              element 'ID', source: 'cbc:CompanyID', properties: {schemeID: -> { 'cac:TaxScheme//cbc:ID' }}
            end
          end
          element 'BuyerTradeParty', source: '//cac:AccountingCustomerParty//cac:Party' do
            element 'ID', source: 'cac:PartyIdentification//cbc:ID', source_properties: [:schemeID]
            element 'Name', source: 'cac:PartyName//cbc:Name'
            element 'SpecifiedLegalOrganization', source: 'cac:PartyLegalEntity' do
              element 'ID', source: 'cbc:CompanyID', source_properties: [:schemeID]
              element 'TradingBusinessName', source: 'cbc:RegistrationName'
              element 'PostalTradeAddress', source: 'cac:RegistrationAddress' do
                element 'CityName', source: 'cbc:CityName'
                element 'CountryID', source: 'cac:Country//cbc:IdentificationCode'
                element 'CountrySubDivisionName', source: 'cbc:CountrySubentity'
              end
            end
            element 'PostalTradeAddress', source: 'cac:PostalAddress' do
              element 'PostcodeCode', source: 'cbc:PostalZone'
              element 'LineOne', source: 'cbc:StreetName'
              element 'LineTwo', source: 'cbc:AdditionalStreetName'
              element 'CityName', source: 'cbc:CityName'
              element 'CountryID', source: 'cac:Country//cbc:IdentificationCode'
              element 'CountrySubDivisionName', source: 'cbc:CountrySubentity'
            end
            element 'URIUniversalCommunication' do
              element 'URIID', source: 'cbc:EndpointID', source_properties: [:schemeID]
            end

            element 'SpecifiedTaxRegistration', source: 'cac:PartyTaxScheme' do
              element 'ID', source: 'cbc:CompanyID', properties: {schemeID: -> { 'cac:TaxScheme//cbc:ID' }}
            end
          end
          element 'BuyerOrderReferencedDocument' do
            element 'IssuerAssignedID', source: '//cac:OrderReference//cbc:ID'
          end
          element 'ContractReferencedDocument' do
            element 'IssuerAssignedID', source: '//cac:ContractDocumentReference//cbc:ID'
          end
          collection 'AdditionalReferencedDocument', source: '//cac:AdditionalDocumentReference' do
            element 'IssuerAssignedID', source: 'cbc:ID'
            element 'URIID', source: 'cac:Attachment//cac:ExternalReference//cbc:URI'
            element 'TypeCode', source: 'cbc:DocumentTypeCode'
            element 'Name', source: 'cbc:DocumentDescription'
            element 'AttachmentBinaryObject', source: 'cac:Attachment//cbc:EmbeddedDocumentBinaryObject'
          end
        end
        element 'ApplicableHeaderTradeDelivery', source: '//cac:Delivery', prefix: PREFIX_RAM do
          element 'ShipToTradeParty' do
            element 'ID', source: 'cac:DeliveryLocation//cbc:ID', source_properties: [:schemeID]
            element 'PostalTradeAddress', source: 'cac:DeliveryLocation//cac:Address' do
              element 'PostcodeCode', source: 'cbc:PostalZone'
              element 'LineOne', source: 'cbc:StreetName'
              element 'LineTwo', source: 'cbc:AdditionalStreetName'
              element 'CityName', source: 'cbc:CityName'
              element 'CountryID', source: 'cac:Country//cbc:IdentificationCode'
              element 'CountrySubDivisionName', source: 'cbc:CountrySubentity'
            end
          end
          element 'ActualDeliverySupplyChainEvent' do
            element 'OccurrenceDateTime' do
              element 'DateTimeString', source: 'cbc:ActualDeliveryDate', properties: {format: '102'},
prefix: PREFIX_UDT
            end
          end
        end
        element 'ApplicableHeaderTradeSettlement', prefix: PREFIX_RAM do
          element 'PaymentReference', source: '//cac:PaymentMeans//cbc:PaymentID'
          element 'InvoiceCurrencyCode', source: '//cbc:DocumentCurrencyCode'
          element 'PayeeTradeParty', source: '//cac:PayeeParty' do
            element 'ID', source: 'cac:PartyIdentification//cbc:ID', source_properties: [:schemeID]
            element 'Name', source: 'cac:PartyName//cbc:Name'
            element 'SpecifiedLegalOrganization', source: 'cac:PartyLegalEntity' do
              element 'ID', source: 'cbc:CompanyID', source_properties: [:schemeID]
            end
          end
          collection 'SpecifiedTradeSettlementPaymentMeans', source: '//cac:PaymentMeans' do
            element 'TypeCode', source: 'cbc:PaymentMeansCode'
            element 'PayeePartyCreditorFinancialAccount', source: 'cac:PayeeFinancialAccount' do
              element 'IBANID', source: 'cbc:ID'
              element 'AccountName', source: 'cbc:Name'
            end
          end
          element 'ApplicableTradeTax', source: '//cac:TaxTotal//cac:TaxSubtotal' do
            element 'CalculatedAmount', source: 'cbc:TaxAmount', source_properties: [:currencyID]
            element 'TypeCode', source: 'cac:TaxCategory//cbc:ID'
            element 'BasisAmount', source: 'cbc:TaxableAmount', source_properties: [:currencyID]
            element 'RateApplicablePercent', source: 'cac:TaxCategory//cbc:Percent'
          end
          element 'BillingSpecifiedPeriod', source: '//cac:InvoicePeriod' do
            element 'StartDateTime' do
              element 'DateTimeString', source: 'cbc:StartDate', properties: {format: '102'}, prefix: PREFIX_UDT
            end
            element 'EndDateTime' do
              element 'DateTimeString', source: 'cbc:EndDate', properties: {format: '102'}, prefix: PREFIX_UDT
            end
          end
          collection 'SpecifiedTradeAllowanceCharge', source: '//cac:AllowanceCharge' do
            element 'ChargeIndicator' do
              element 'Indicator', source: 'cbc:ChargeIndicator', prefix: PREFIX_UDT
            end
            element 'ActualAmount', source: 'cbc:Amount'
            element 'Reason', source: 'cbc:AllowanceChargeReason'
          end
          element 'SpecifiedTradePaymentTerms' do
            element 'Description', source: '//cac:PaymentTerms//cbc:Note'
            element 'DueDateDateTime', source: '//cac:PaymentMeans' do
              element 'DateTimeString', source: 'cbc:PaymentDueDate', properties: {format: '102'}, prefix: PREFIX_UDT
            end
          end
          element 'SpecifiedTradeSettlementHeaderMonetarySummation' do
            element 'LineTotalAmount', source:            '//cac:LegalMonetaryTotal//cbc:LineExtensionAmount',
                                       source_properties: [:currencyID]
            element 'ChargeTotalAmount', source:            '//cac:LegalMonetaryTotal//cbc:ChargeTotalAmount',
                                         source_properties: [:currencyID]
            element 'AllowanceTotalAmount', source:            '//cac:LegalMonetaryTotal//cbc:AllowanceTotalAmount',
                                            source_properties: [:currencyID]
            element 'TaxBasisTotalAmount', source:            '//cac:LegalMonetaryTotal//cbc:TaxExclusiveAmount',
                                           source_properties: [:currencyID]
            element 'TaxTotalAmount', source: '//cac:TaxTotal//cbc:TaxAmount', source_properties: [:currencyID]
            element 'RoundingAmount', source:            '//cac:LegalMonetaryTotal//cbc:PayableRoundingAmount',
                                      source_properties: [:currencyID]
            element 'GrandTotalAmount', source:            '//cac:LegalMonetaryTotal//cbc:TaxInclusiveAmount',
                                        source_properties: [:currencyID]
            element 'TotalPrepaidAmount', source:            '//cac:LegalMonetaryTotal//cbc:PrepaidAmount',
                                          source_properties: [:currencyID]
            element 'DuePayableAmount', source:            '//cac:LegalMonetaryTotal//cbc:PayableAmount',
                                        source_properties: [:currencyID]
          end
          element 'ReceivableSpecifiedTradeAccountingAccount' do
            element 'ID', source: '//cbc:AccountingCost'
          end
        end
      end
    end
  end
end
