Gem::Specification.new do |s|
  s.name = %q{foxbat}
  s.version = "0.0.1"
  s.authors = ["Chris Mowforth"]
  s.email = ["chris@mowforth.com"]
  s.summary = "EventMachine replacement for JRuby."
  s.description = <<-EOF
    A drop-in replacement for EventMachine, designed & build from the ground-up around Java 7 A/IO.
  EOF
  s.files = Dir.glob("{lib}/**/*")
  s.homepage = "http://github.com/cmowforth/foxbat"
  s.has_rdoc = false
end