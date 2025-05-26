# UblToCiiConverter

A Ruby Gem to convert UBL XML files to CII XML files.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ubl2cii'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install ubl2cii
```

## Usage

### Basic Usage Example

Here is a simple example of converting a UBL XML file to a CII XML file using the `Ubl2Cii::Converter` class.

```ruby
require 'ubl2cii'

# Read the UBL XML file
ubl_xml = File.read('path/to/ubl_invoice.xml')

# Initialize the converter
converter = Ubl2Cii::Converter.new(ubl_xml)

# Convert to CII XML
cii_xml = converter.convert_to_cii

# Output the resulting CII XML
File.write('path/to/cii_invoice.xml', cii_xml)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Dependencies

This project depends on the following gems:

- `nokogiri` (>= 1.18)

## Running Tests

To run the tests, execute:

```bash
$ bundle exec rake spec
```
