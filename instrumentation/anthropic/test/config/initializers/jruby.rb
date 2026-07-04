# Deterministic Anthropic model loading for JRuby only.

return unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"

spec = Gem.loaded_specs["anthropic"]
return unless spec

# --- 1. Predefine the module tree Anthropic forgot to define ---
module Anthropic
  module Beta; end
  module Models
    module Beta; end
    module Messages; end
    module Tools; end
  end
end

# --- 2. Deterministically require all model files ---
base = File.join(spec.full_gem_path, "lib", "anthropic", "models")

Dir[File.join(base, "**", "*.rb")].sort.each do |file|
  require file
end
