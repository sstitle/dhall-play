# Config comes from the shell wrapper (Dhall → Nix → env → Nushell).
let cfg = {
  greeting: $env.NU_GREETING
  name: $env.NU_NAME
  style: $env.NU_STYLE
  tags: ($env.NU_TAGS_JSON | from json)
  note: $env.NU_NOTE
}

print "Hello world — Dhall configuration (flexible schema)"
print ""

print "Table (keys and values):"
$cfg | transpose key value | table | print

print ""
print "Tags (list from schema):"
$cfg.tags | each { |t| print $"  - ($t)" }

print ""
print "Note (extra field on schema):"
print $"  ($cfg.note)"

print ""
print "JSON (pretty):"
$cfg | to json --indent 2 | print
