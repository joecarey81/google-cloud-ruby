# Copyright 2017 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

gem "minitest"
require "minitest/autorun"
require "minitest/focus"
require "minitest/rg"
require "ostruct"
require "json"
require "base64"
require "google/cloud/debugger"

class MockDebugger < Minitest::Spec
  let(:project) { "test" }
  let(:default_options) { Google::Gax::CallOptions.new(kwargs: { "google-cloud-resource-prefix" => "projects/#{project}" }) }
  let(:credentials) { OpenStruct.new(client: OpenStruct.new(updater_proc: Proc.new {})) }
  let(:module_name) { "test-service" }
  let(:module_version) { "vTest" }
  let(:service) {
    service = Google::Cloud::Debugger::Service.new(project, credentials)
    mocked_debugger = Object.new
    mocked_transmitter = Object.new
    mocked_debugger.define_singleton_method :register_debuggee do |*_| end
    mocked_debugger.define_singleton_method :list_active_breakpoints do |*_| end
    mocked_transmitter.define_singleton_method :update_active_breakpoint do |*_| end

    service.mocked_debugger = mocked_debugger
    service.mocked_transmitter = mocked_transmitter
    service
  }
  let(:debugger) {
    Google::Cloud::Debugger::Project.new(
      service,
      module_name: module_name,
      module_version: module_version
    )
  }
  let(:debuggee_id) { "test debuggee id" }
  let(:debuggee) {
    agent.debuggee.instance_variable_set :@id, debuggee_id
    agent.debuggee
  }
  let(:agent) { debugger.agent }
  let(:breakpoint_manager) {
    manager = agent.breakpoint_manager
    manager.on_breakpoints_change = nil
    manager
  }
  let(:tracer) { agent.tracer }
  let(:transmitter) { agent.transmitter }

  # Register this spec type for when :speech is used.
  register_spec_type(self) do |desc, *addl|
    addl.include? :mock_debugger
  end

  def random_source_location_hash
    {
      "path" => "my_app/my_class.rb",
      "line" => 321
    }
  end

  def random_variable_integer_hash
    {
      "name" => "[0]",
      "type" => "Integer",
      "value" => "3",
      "members" => []
    }
  end

  def random_variable_array_hash
    {
      "name" => "local_var",
      "type" => "Array",
      "members" => [
        random_variable_integer_hash
      ]
    }
  end

  def random_stack_frame_hash
    {
      "function" => "index",
      "location" => random_source_location_hash,
      "arguments" => [random_variable_integer_hash],
      "locals" => [random_variable_array_hash]
    }
  end

  def random_breakpoint_hash
    timestamp = Time.parse "2014-10-02T15:01:23.045123456Z"
    {
      "id" => "abc123",
      "action" => :CAPTURE,
      "location" => random_source_location_hash,
      "create_time" => {
        "seconds" => timestamp.to_i,
        "nanos"   => timestamp.nsec
      },
      "final_time" => {
        "seconds" => timestamp.to_i,
        "nanos"   => timestamp.nsec
      },
      "stack_frames" => [random_stack_frame_hash],
      "condition" => "i == 2",
      "expressions" => ["[3]"],
      "evaluated_expressions" => [random_variable_array_hash],
      "labels" => {
        "tag" => "hello"
      },
      "variable_table" => [random_variable_array_hash]
    }
  end
end

# Mock Rack::Directory
module Rack
  class Directory
    def initialize arg
    end

    # Spoof with current test directory
    def root
      ::File.expand_path "."
    end
  end
end

##
# Helper method to loop until block yields true or timeout.
def wait_until_true timeout = 5
  begin_t = Time.now

  until yield
    return :timeout if Time.now - begin_t > timeout
    sleep 0.1
  end

  :completed
end
