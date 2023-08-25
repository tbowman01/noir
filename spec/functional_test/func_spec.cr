require "../../src/models/noir.cr"
require "../../src/models/endpoint.cr"

module Noir
    VERSION = "SPEC"
end

class FunctionalTester
    # expected_count's symbols are:
    # :techs
    # :endpoints
    @expected_count : Hash(Symbol, Int32)
    @expected_endpoints : Array(Endpoint)
    @app : NoirRunner
    @path : String

    def initialize (@path, expected_count, expected_endpoints)
        noir_options = default_options()
        noir_options[:base] = "./spec/functional_test/#{@path}"
        noir_options[:nolog] = "yes"

        if !expected_count.nil?
            @expected_count = expected_count
        else
            @expected_count = Hash(Symbol, Int32).new
        end

        if !expected_endpoints.nil?
            @expected_endpoints = expected_endpoints
        else
            @expected_endpoints = Array(Endpoint).new
        end

        @app = NoirRunner.new noir_options
    end

    def test_detect
        @app.detect
        if @expected_count.has_key?(:techs)
            it "test detect using count check" do
                @app.techs.size.should eq @expected_count[:techs]
            end
        end
    end

    def find_endpoint (key)
        @expected_endpoints.each do | endpoint |
            expected_key = endpoint.method.to_s + "::" +endpoint.url.to_s
            if expected_key.to_s == key.to_s
                return endpoint
            end
        end
        return nil
    end

    def find_param (param_name)
        if @expected_endpoints.params.size > 0
            @expected_endpoints.params.each do | param |
                if param.name.to_s == param_name.to_s
                    return param
                end
            end
        end
        
        return nil
    end

    def test_analyze
        @app.analyze
        if @expected_count.has_key?(:endpoints)
            it "test analyze using count check" do
                @app.endpoints.size.should eq @expected_count[:endpoints]
            end
        end

        if @expected_endpoints.size > 0
            @app.endpoints.each do | endpoint |
                key = endpoint.method.to_s + "::" + endpoint.url.to_s
                found_endpoint = find_endpoint key
                if found_endpoint.nil?
                    it "endpoint check - nil" do
                        false.should eq true
                    end
                else
                    it "endpoint check - url [K: #{key}]" do
                        endpoint.url.should eq found_endpoint.url
                    end

                    it "endpoint check - method [K: #{key}]" do
                        endpoint.method.should eq found_endpoint.method
                    end

                    if endpoint.params.size > 0
                        endpoint.params.each do | param |
                            found_param = found_endpoint.params.find { | p | p.name == param.name }
                            if found_param.nil?
                                it "endpoint check - params nil [K: #{key}]" do
                                    false.should eq true
                                end
                            else
                                it "endpoint check - params [K: #{key}]" do
                                    param.name.should eq found_param.name
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    def test_all
        describe "Functional test to #{@path}" do
            test_detect
            test_analyze
        end
    end
end