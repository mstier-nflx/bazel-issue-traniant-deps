# Useful rule to see if a different package is loaded before a particular step in WORKSPACE.
our_version = True

def ensure_version(rule, name, patches = [], **kwargs):
    if name in native.existing_rules():
        fail("""
Someone already loaded %s, try placing our version somewhere earlier in WORKSPACE.
Previously loaded rule details:
%s
""" % (name, native.existing_rules()[name]))

    rule(
        name = name,
        patches = ["//:version_witness.patch"] + patches,
        **kwargs
    )
