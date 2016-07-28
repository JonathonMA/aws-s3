require 'cgi'
require 'uri'
require 'openssl'
require 'digest/sha1'
require 'net/https'
require 'time'
require 'date'
require 'open-uri'

require 'aws/s3/extensions'
require_library_or_gem 'builder' unless defined? Builder
require_library_or_gem 'mime/types', 'mime-types' unless defined? MIME::Types

require 'aws/s3/base'
require 'aws/s3/version'
require 'aws/s3/parsing'
require 'aws/s3/acl'
require 'aws/s3/logging'
require 'aws/s3/bittorrent'
require 'aws/s3/service'
require 'aws/s3/owner'
require 'aws/s3/bucket'
require 'aws/s3/object'
require 'aws/s3/error'
require 'aws/s3/exceptions'
require 'aws/s3/connection'
require 'aws/s3/authentication'
require 'aws/s3/response'

module AWS
  module S3
    UNSAFE_URI = /[^-_.!~*'()a-zA-Z\d;\/?:@&=$,\[\]]/n

    def self.escape_uri(path)
      URI.escape(path.to_s, UNSAFE_URI)
    end

    def self.escape_uri_component(path)
      escaped = escape_uri(path)
      escaped.gsub!(/=/, '%3D')
      escaped.gsub!(/&/, '%26')
      escaped.gsub!(/;/, '%3B')
      escaped
    end

    Base.class_eval do
      include AWS::S3::Connection::Management
    end

    Bucket.class_eval do
      include AWS::S3::Logging::Management
      include AWS::S3::ACL::Bucket
    end

    S3Object.class_eval do
      include AWS::S3::ACL::S3Object
      include AWS::S3::BitTorrent
    end
  end
end


require_library_or_gem 'xmlsimple', 'xml-simple' unless defined? XmlSimple
# If libxml is installed, we use the FasterXmlSimple library, that provides most of the functionality of XmlSimple
# except it uses the xml/libxml library for xml parsing (rather than REXML). If libxml isn't installed, we just fall back on
# XmlSimple.
AWS::S3::Parsing.parser =
  begin
    require_library_or_gem 'xml/libxml'
    # Older version of libxml aren't stable (bus error when requesting attributes that don't exist) so we
    # have to use a version greater than '0.3.8.2'.
    raise LoadError unless XML::Parser::VERSION > '0.3.8.2'
    $:.push(File.join(File.dirname(__FILE__), '..', '..', 'support', 'faster-xml-simple', 'lib'))
    require_library_or_gem 'faster_xml_simple' 
    FasterXmlSimple
  rescue LoadError
    XmlSimple
  end
