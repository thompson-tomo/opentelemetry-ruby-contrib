# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module ActiveJob
      module Mappers
        # Maps ActiveJob Attributes to Semantic Conventions
        class Attribute
          # Generates a set of attributes to add to a span using
          # `rails.active_job.*` namespace for custom attributes
          #
          # @param payload [Hash] of an ActiveSupport::Notifications payload
          # @return [Hash<String, Object>] of semantic attributes
          def call(payload)
            job = payload.fetch(:job)

            otel_attributes = {
              'rails.active_job.task.name' => job.class.name,
              'rails.active_job.queue.name' => job.queue_name,
              'rails.active_job.job.id' => job.job_id,
              'rails.active_job.queue.adapter.name' => job.class.queue_adapter_name
            }

            # Not all adapters generate or provide back end specific ids for messages
            otel_attributes['rails.active_job.job.external_id'] = job.provider_job_id.to_s if job.provider_job_id
            # This can be problematic if programs use invalid attribute types like Symbols for priority instead of using Integers.
            otel_attributes['rails.active_job.job.priority'] = job.priority.to_s if job.priority

            otel_attributes.compact!

            otel_attributes
          end
        end
      end
    end
  end
end
