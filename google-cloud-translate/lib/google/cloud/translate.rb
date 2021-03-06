# Copyright 2016 Google Inc. All rights reserved.
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


require "google-cloud-translate"
require "google/cloud/translate/api"

module Google
  module Cloud
    ##
    # # Google Cloud Translation API
    #
    # [Google Cloud Translation API](https://cloud.google.com/translation/)
    # provides a simple, programmatic interface for translating an arbitrary
    # string into any supported language. It is highly responsive, so websites
    # and applications can integrate with Translation API for fast, dynamic
    # translation of source text. Language detection is also available in cases
    # where the source language is unknown.
    #
    # Translation API supports more than one hundred different languages, from
    # Afrikaans to Zulu. Used in combination, this enables translation between
    # thousands of language pairs. Also, you can send in HTML and receive HTML
    # with translated text back. You don't need to extract your source text or
    # reassemble the translated content.
    #
    # ## Authenticating
    #
    # Like other Cloud Platform services, Google Cloud Translation API supports
    # authentication using a project ID and OAuth 2.0 credentials. In addition,
    # it supports authentication using a public API access key. (If both the API
    # key and the project and OAuth 2.0 credentials are provided, the API key
    # will be used.) Instructions and configuration options are covered in the
    # [Authentication Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-translate/guides/authentication).
    #
    # ## Translating texts
    #
    # Translating text from one language to another is easy (and extremely
    # fast.) The only required arguments to
    # {Google::Cloud::Translate::Api#translate} are a string and the [ISO
    # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) code of the
    # language to which you wish to translate.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # translation = translate.translate "Hello world!", to: "la"
    #
    # puts translation #=> Salve mundi!
    #
    # translation.from #=> "en"
    # translation.origin #=> "Hello world!"
    # translation.to #=> "la"
    # translation.text #=> "Salve mundi!"
    # ```
    #
    # You may want to use the `from` option to specify the language of the
    # source text, as the following example illustrates. (Single words do not
    # give Translation API much to work with.)
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # translation = translate.translate "chat", to: "en"
    #
    # translation.detected? #=> true
    # translation.from #=> "en"
    # translation.text #=> "chat"
    #
    # translation = translate.translate "chat", from: "fr", to: "en"
    #
    # translation.detected? #=> false
    # translation.from #=> "fr"
    # translation.text #=> "cat"
    # ```
    #
    # You can pass multiple texts to {Google::Cloud::Translate::Api#translate}.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # translations = translate.translate "chien", "chat", from: "fr", to: "en"
    #
    # translations.size #=> 2
    # translations[0].origin #=> "chien"
    # translations[0].text #=> "dog"
    # translations[1].origin #=> "chat"
    # translations[1].text #=> "cat"
    # ```
    #
    # By default, any HTML in your source text will be preserved.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # translation = translate.translate "<strong>Hello</strong> world!",
    #                                   to: :la
    # translation.text #=> "<strong>Salve</strong> mundi!"
    # ```
    #
    # ## Detecting languages
    #
    # You can use {Google::Cloud::Translate::Api#detect} to see which language
    # the Translation API ranks as the most likely source language for a text.
    # The `confidence` score is a float value between `0` and `1`.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # detection = translate.detect "chat"
    #
    # detection.text #=> "chat"
    # detection.language #=> "en"
    # detection.confidence #=> 0.59922177
    # ```
    #
    # You can pass multiple texts to {Google::Cloud::Translate::Api#detect}.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # detections = translate.detect "chien", "chat"
    #
    # detections.size #=> 2
    # detections[0].text #=> "chien"
    # detections[0].language #=> "fr"
    # detections[0].confidence #=> 0.7109375
    # detections[1].text #=> "chat"
    # detections[1].language #=> "en"
    # detections[1].confidence #=> 0.59922177
    # ```
    #
    # ## Listing supported languages
    #
    # Translation API adds new languages frequently. You can use
    # {Google::Cloud::Translate::Api#languages} to query the list of supported
    # languages.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # languages = translate.languages
    #
    # languages.size #=> 104
    # languages[0].code #=> "af"
    # languages[0].name #=> nil
    # ```
    #
    # To receive the names of the supported languages, as well as their [ISO
    # 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) codes,
    # provide the code for the language in which you wish to receive the names.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new
    #
    # languages = translate.languages "en"
    #
    # languages.size #=> 104
    # languages[0].code #=> "af"
    # languages[0].name #=> "Afrikaans"
    # ```
    #
    # ## Configuring retries and timeout
    #
    # You can configure how many times API requests may be automatically
    # retried. When an API request fails, the response will be inspected to see
    # if the request meets criteria indicating that it may succeed on retry,
    # such as `500` and `503` status codes or a specific internal error code
    # such as `rateLimitExceeded`. If it meets the criteria, the request will be
    # retried after a delay. If another error occurs, the delay will be
    # increased before a subsequent attempt, until the `retries` limit is
    # reached.
    #
    # You can also set the request `timeout` value in seconds.
    #
    # ```ruby
    # require "google/cloud/translate"
    #
    # translate = Google::Cloud::Translate.new retries: 10, timeout: 120
    # ```
    #
    module Translate
      ##
      # Creates a new object for connecting to Cloud Translation API. Each call
      # creates a new connection.
      #
      # Like other Cloud Platform services, Google Cloud Translation API
      # supports authentication using a project ID and OAuth 2.0 credentials. In
      # addition, it supports authentication using a public API access key. (If
      # both the API key and the project and OAuth 2.0 credentials are provided,
      # the API key will be used.) Instructions and configuration options are
      # covered in the [Authentication
      # Guide](https://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-translate/guides/authentication).
      #
      # @param [String] project Identifier for the Cloud Translation API project
      #   to which you are connecting.
      # @param [String, Hash] keyfile Keyfile downloaded from Google Cloud. If
      #   file path the file must be readable.
      # @param [String, Array<String>] scope The OAuth 2.0 scopes controlling
      #   the set of resources and operations that the connection can access.
      #   See [Using OAuth 2.0 to Access Google
      #   APIs](https://developers.google.com/identity/protocols/OAuth2).
      #
      #   The default scope is:
      #
      #   * `https://www.googleapis.com/auth/cloud-platform`
      # @param [String] key a public API access key (not an OAuth 2.0 token)
      # @param [Integer] retries Number of times to retry requests on server
      #   error. The default value is `3`. Optional.
      # @param [Integer] timeout Default timeout to use in requests. Optional.
      #
      # @return [Google::Cloud::Translate::Api]
      #
      # @example
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new(
      #     project: "my-todo-project",
      #     keyfile: "/path/to/keyfile.json"
      #   )
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      # @example Using API Key.
      #   require "google/cloud/translate"
      #
      #   translate = Google::Cloud::Translate.new(
      #     key: "api-key-abc123XYZ789"
      #   )
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      # @example Using API Key from the environment variable.
      #   require "google/cloud/translate"
      #
      #   ENV["TRANSLATE_KEY"] = "api-key-abc123XYZ789"
      #
      #   translate = Google::Cloud::Translate.new
      #
      #   translation = translate.translate "Hello world!", to: "la"
      #   translation.text #=> "Salve mundi!"
      #
      def self.new project: nil, keyfile: nil, scope: nil, key: nil,
                   retries: nil, timeout: nil
        project ||= Google::Cloud::Translate::Api.default_project
        project = project.to_s # Always cast to a string

        key ||= ENV["TRANSLATE_KEY"]
        key ||= ENV["GOOGLE_CLOUD_KEY"]
        if key
          return Google::Cloud::Translate::Api.new(
            Google::Cloud::Translate::Service.new(
              project, nil, retries: retries, timeout: timeout, key: key))
        end

        if keyfile.nil?
          credentials = Google::Cloud::Translate::Credentials.default(
            scope: scope)
        else
          credentials = Google::Cloud::Translate::Credentials.new(
            keyfile, scope: scope)
        end

        Google::Cloud::Translate::Api.new(
          Google::Cloud::Translate::Service.new(
            project, credentials, retries: retries, timeout: timeout))
      end
    end
  end
end
