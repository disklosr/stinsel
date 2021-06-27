# This is a custom ansible filter to allow hashing 
# authelia password during deploy using argon2 function

# Make sure you  'pip3 install --user argon2-cffi' so this filter can work

from argon2 import PasswordHasher
import argon2

# These params are also defines in authelia config file!
ph = PasswordHasher(
    time_cost=1, 
    type=argon2.Type.ID, 
    memory_cost=64, 
    parallelism=8,
    hash_len=32
)

class FilterModule(object):
    def filters(self):
        return {'argon2_hash': self.compute_hash}

    def compute_hash(self, password):
        return ph.hash(password)