# This file used to provide #with_tracking / #without_tracking functionality.
# We realised it was as useful outside of tests as inside tests, so we've
# made it threadsafe and a part of the default API.

# If you're reading this, remove any `require 'public_activity/testing'` you
# might have, it's completely redundant.
