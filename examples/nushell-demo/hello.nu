# Config comes from the shell wrapper (Dhall → Nix → env).
let cfg = {
  greeting: $env.NU_GREETING
  name: $env.NU_NAME
  style: $env.NU_STYLE
}

print "Hello world — Dhall configuration"
print ""

print "Table (keys and values):"
$cfg | transpose key value | table | print

print ""
print "JSON (pretty):"
$cfg | to json --indent 2 | print
