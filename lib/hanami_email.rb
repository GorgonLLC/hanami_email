require "json"
require "typhoeus"

class HanamiEmail
  class << self
    [:default_domain, :api_key, :timeout, :connecttimeout].each do |opt|
      define_method(:"#{opt}=") {|val| instance_variable_set(:"@#{opt}", val)}
      define_method(opt) { begin; instance_variable_get(:"@#{opt}"); rescue NameError; nil; end }
    end
  end

  def self.configure
    yield self
  end

  class TimeoutError < StandardError; end
  class NoHTTPResponseError < StandardError; end
  class NonSuccessfulHTTPError < StandardError; end

  class BaseRequest
    attr_reader :domain, :api_key, :params

    def initialize(params={})
      @api_key = params.delete(:api_key) || ::HanamiEmail.api_key
      raise ":api_key param or config option is required" unless @api_key
      @domain = params.delete(:domain) || ::HanamiEmail.default_domain
      raise ":domain param or :default_domain config option is required" unless @domain
      @params = params
    end

    def default_params
      {
        timeout: ::HanamiEmail.timeout || 15,
        connecttimeout: ::HanamiEmail.connecttimeout || 15,
        followlocation: true,
        headers: {
          "Content-Type"  => "application/json",
          "apikey" => api_key,
        },
      }
    end

    def wrap_error(response)
      response.tap do |response|
        if response.timed_out?
          raise TimeoutError, response
        elsif response.code == 0
          raise NoHTTPResponseError, response
        elsif !response.success?
          raise NonSuccessfulHTTPError, response
        end
      end
    end
  end

  class Alias < BaseRequest
    def self.list(*args, &blk)
      self.new(*args, &blk).list
    end

    def self.create(*args, &blk)
      self.new(*args, &blk).create
    end

    def self.delete(*args, &blk)
      self.new(*args, &blk).delete
    end

    def list
      JSON.parse(wrap_error(
        Typhoeus.get(
          "https://api.mailwip.com/v1/domains/#{domain}/aliases",
          default_params,
        )
      ).body)
    end

    def create
      JSON.parse(wrap_error(
        Typhoeus.post(
          "https://api.mailwip.com/v1/domains/#{domain}/aliases",
          default_params.merge({ body: params.to_json }),
        )
      ).body)
    end

    def delete
      JSON.parse(wrap_error(
        Typhoeus.delete(
          "https://api.mailwip.com/v1/domains/#{domain}/aliases",
          default_params.merge({ body: params.to_json }),
        )
      ).body)
    end
  end
end
