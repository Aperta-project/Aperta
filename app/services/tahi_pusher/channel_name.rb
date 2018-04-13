# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module TahiPusher
  class ChannelResourceNotFound < StandardError; end

  class ChannelName
    CHANNEL_SEPARATOR = "-".freeze
    MODEL_SEPARATOR   = "@".freeze
    PRESENCE          = "presence".freeze
    PRIVATE           = "private".freeze
    PUBLIC            = "public".freeze
    SYSTEM            = "system".freeze
    ADMIN             = "admin".freeze

    # <#Paper:1234 @id=4> --> "private-paper@4"
    def self.build(target:, access:)
      raise ChannelResourceNotFound.new("Channel target cannot be nil") if target.nil?

      prefix = access unless access == PUBLIC
      suffix = if target.is_a?(ActiveRecord::Base)
                 [target.class.name.underscore, target.id].join(MODEL_SEPARATOR)
               else
                 target
               end
      [prefix, suffix].compact.join(CHANNEL_SEPARATOR)
    end

    # "private-paper@4" --> <#TahiPusher::ChannelName @prefix="private" @suffix="paper@4">
    def self.parse(channel_name)
      new(channel_name)
    end


    attr_reader :name, :prefix, :suffix

    def initialize(name)
      @name = name
      @prefix, _, @suffix = name.rpartition(CHANNEL_SEPARATOR)
    end

    def access
      prefix.presence || PUBLIC
    end

    def target
      model, _, id = suffix.partition(MODEL_SEPARATOR)
      if active_record_backed?
        model.classify.constantize.find(id)
      else
        model
      end
    rescue ActiveRecord::RecordNotFound
      raise ChannelResourceNotFound
    end

    # "private-paper@4" --> true, "system" --> false
    def active_record_backed?
      model, _ = suffix.partition(MODEL_SEPARATOR)
      return false if model == SYSTEM
      model.classify.constantize.new.is_a?(ActiveRecord::Base)
    rescue NameError
      false # model could not be constantized
    end
  end
end
