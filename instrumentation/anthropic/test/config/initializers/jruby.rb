# Deterministic Anthropic model loading for JRuby only.
# MRI behaviour is untouched.

return unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"

spec = Gem.loaded_specs["anthropic"]
# Bail out quietly if the gem isn't present (e.g., partial bundle groups).
return unless spec

base = File.join(spec.full_gem_path, "lib", "anthropic", "models")

# Directories we want to force‑load in a stable order.
# Extend this list if Anthropic adds more model namespaces.
dirs = [
  "",          # top‑level models (lib/anthropic/models/*.rb)
  "beta",      # lib/anthropic/models/beta/**/*.rb
  "messages",  # example: lib/anthropic/models/messages/**/*.rb
  "tools"      # example: lib/anthropic/models/tools/**/*.rb
].uniq

dirs.each do |subdir|
  pattern =
    if subdir.empty?
      File.join(base, "*.rb")
    else
      File.join(base, subdir, "**", "*.rb")
    end

  Dir[pattern].sort.each do |file|
    # `require` is idempotent; JRuby gets deterministic ordering,
    # MRI keeps its normal autoload behaviour.
    require file
  end
end
``````ruby
# config/initializers/anthropic_jruby.rb
# Deterministic Anthropic model loading for JRuby only.
# MRI behaviour is untouched.

return unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"

spec = Gem.loaded_specs["anthropic"]
# Bail out quietly if the gem isn't present (e.g., partial bundle groups).
return unless spec

base = File.join(spec.full_gem_path, "lib", "anthropic", "models")

# Directories we want to force‑load in a stable order.
# Extend this list if Anthropic adds more model namespaces.
dirs = [
  "",          # top‑level models (lib/anthropic/models/*.rb)
  "beta",      # lib/anthropic/models/beta/**/*.rb
  "messages",  # example: lib/anthropic/models/messages/**/*.rb
  "tools"      # example: lib/anthropic/models/tools/**/*.rb
].uniq

dirs.each do |subdir|
  pattern =
    if subdir.empty?
      File.join(base, "*.rb")
    else
      File.join(base, subdir, "**", "*.rb")
    end

  Dir[pattern].sort.each do |file|
    # `require` is idempotent; JRuby gets deterministic ordering,
    # MRI keeps its normal autoload behaviour.
    require file
  end
end
