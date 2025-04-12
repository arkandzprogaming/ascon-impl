## Rewriting Ascon-Hash v1.2 in Python ##
## From https://github.com/meichlseder/pyascon/blob/5ee786cdc8a74d9c0f7b3c81f99f5dcb5490ca00/ascon.py ##

debug = False
debugpermutation = False

#-- Ascon-Hash v1.2
def ascon_hash(message, hashlength = 32):
    """
    message: a bytes object of arbitrary length
    variant: "Ascon-Hash" : 256-bit output for 128-bit security
    hashlength: The requested output length in bytes (32 bytes for Ascon-Hash)
    returns an object containing the hash tag
    """
    a = 12 # Number of rounds in Ascon permutation
    b = 12
    rate = 8 # Rate of the sponge construction (bytes)

    # Initialization phase --------------------------------------------
    tagspec = int_to_bytes(256, 4)  # Byte array output: b'\x00\x00\x01\x00' : 256 in big-endian : 00000001 00000000

    # Concatenation into a bytes object of length 4 + 4 + 32 = 40 bytes (S : state)
    """
    A state S is a 40-byte array of the form five 8-byte blocks: S = (S0, S1, S2, S3, S4).

    S0 = 0x00 || rate * 8 || a || a - b || tagspec || tagspec || tagspec || tagspec
    S1 = 0x00 || 0x00     || 0x00 || 0x00 || 0x00    || 0x00  || 0x00    || 0x00
    S2 = 0x00 || 0x00     || 0x00 || 0x00 || 0x00    || 0x00  || 0x00    || 0x00
    S3 = 0x00 || 0x00     || 0x00 || 0x00 || 0x00    || 0x00  || 0x00    || 0x00
    S4 = 0x00 || 0x00     || 0x00 || 0x00 || 0x00    || 0x00  || 0x00    || 0x00
    """
    S = bytes_to_state(bytes([0, rate * 8, a, a - b]) + tagspec + zero_bytes(32))
    if debug: printstate(S, "Initial state value: ")

    ascon_permutation(S, a)
    if debug: printstate(S, "Initialization: ")

    # Message absorption phase -----------------------------------------
    m_padding = bytes([0x80]) + zero_bytes(rate - (len(message) % rate) - 1)
    '''
    if len(message) < len(rate) : 
        len(m_padding) == (rate - len(message))
        len(m_padded) == len(message) + len(m_padding) == rate
    else:
        len(m_padding) == (rate - len(message) % rate)
        len(m_padded) == len(message) + len(m_padding) == rate * (len(message) // rate + 1)
    '''
    m_padded = message + m_padding

    # All blocks except the last one
    for block in range(0, len(m_padded) - rate, rate):
        # Absorbing each 8-byte block into the state
        S[0] ^= int.from_bytes(m_padded[block:block + 8], 'big')
        # Ensuring the impact of the block diffused throughout the state
        ascon_permutation(S, b)
    # Last block
    block = len(m_padded) - rate
    S[0] ^= int.from_bytes(m_padded[block:block + 8], 'big')
    if debug: printstate(S, "Absorption: ")

    # Tag squeezing phase ---------------------------------------------
    H = b""
    ascon_permutation(S, a)
    while len(H) < hashlength:
        # Each iteration appends 8 bytes to H, so the loop iterates over 4 times before it terminates.
        H += int_to_bytes(S[0], 8)  
        ascon_permutation(S, b)
    if debug: printstate(S, "Squeezing: ")
    return H[:hashlength]

#-- Ascon permutation
def ascon_permutation(S, rounds = 1):
    """
    Ascon core permutation for the sponge construction - internal helper function.
    S: Ascon state, a list of 5 64-bit (16-digit hex) integers
    rounds: Number of rounds to perform
    returns nothing, updates S
    """
    assert(rounds <= 12)
    if debugpermutation: printwords(S, "Input to permutation: ")
    for r in range(12 - rounds, 12, 1):
        
        # Add round constants -----------------------------------------
        S[2] ^= (0xf0 - r*0x10 + r*0x01)
        if debugpermutation: printwords(S, f"Round-{r}:\n -- round constant update: ")
        
        # Substitution layer ------------------------------------------
        """
        The substitution layer consists of bitwise operations of the state words.
        This provides confusion and non-linearity to the state, ensuring that small 
        differences in input produce significant differences in output.
        """
        # Combining words using XOR
        S[0] ^= S[4]
        S[4] ^= S[3]
        S[2] ^= S[1]
        # Applying bitwise confusion and non-linearity
        T = [(S[i] ^ 0xFFFFFFFFFFFFFFFF) & S[(i+1)%5] for i in range(5)]
        # Further XOR-ing state with 1-rotated-left version of T
        for i in range(5):
            S[i] ^= T[(i+1)%5]
        # Additional XOR operations
        S[1] ^= S[0]
        S[0] ^= S[4]
        S[3] ^= S[2]
        S[2] ^= 0XFFFFFFFFFFFFFFFF  # Negation of S[2]
        if debugpermutation: printwords(S, " -- substitution layer: ")
        
        # Linear diffusion layer --------------------------------------
        S[0] ^= rotr(S[0], 19) ^ rotr(S[0], 28)
        S[1] ^= rotr(S[1], 61) ^ rotr(S[1], 39)
        S[2] ^= rotr(S[2],  1) ^ rotr(S[2],  6)
        S[3] ^= rotr(S[3], 10) ^ rotr(S[3], 17)
        S[4] ^= rotr(S[4],  7) ^ rotr(S[4], 41)
        if debugpermutation: printwords(S, " -- linear diffusion layer: ")

#-- Helper functions
# Function to return a zero-filled bytes object of a specified length
def zero_bytes(nbytes):
    """
    Return a zero-filled byte array of a specified length.
    
    Args:
        nbytes (int): The number of bytes in the resulting byte array.
        
    Returns:
        bytes: The zero-filled byte array.
    """
    return bytes(nbytes)

# Function to convert a bytes object to a state object (appended list of 5 integers)
def bytes_to_state(bytes_param):
    """
    Convert a byte array to a state object == a list compr. of 5 integers.
    
    Args:
        bytes (bytes): The bytes object to convert.
                     : The length is 40 bytes (5 * 8 bytes).
        
    Returns:
        list: The state object representation of the byte array.
    """
    return [int.from_bytes(bytes(bytes_param)[i:i + 8], 'big') for i in range(0, len(bytes_param), 8)]

# Function to convert an integer to a bytes object of specified length
def int_to_bytes(integer, nbytes):
    """
    Convert an integer to a byte array of a specified length.
    
    Args:
        integer (int): The integer to convert.
        nbytes (int): The number of bytes in the resulting byte array.
        
    Returns:
        bytes: The byte array representation of the integer.
    """
    return bytes((integer >> ((nbytes - 1 - i) * 8)) & 0xff for i in range(nbytes))

# Function to perform a right rotation of a 64-bit integer by a specified number of bits
def rotr(val, n):
    """
    Perform a right rotation of a 64-bit integer by a specified number of bits.
    
    Args:
        val (int): The integer to rotate.
        n (int): The number of bits to rotate by.
        
    Returns:
        int: The rotated integer.
    """
    return ((val >> n) | (val << (64 - n))) & 0xFFFFFFFFFFFFFFFF    # 64-bit mask

#-- Printing functions
# Function to print the state object
def printstate(S, description=""):
    print(" " + description)
    print(" ".join(["{s:016x}".format(s=s) for s in S]))

# Function to print the state object as words
def printwords(S, description=""):
    print(" " + description)
    print("\n".join([f"  x{i}={s:016x}" for i, s in enumerate(S)]))

#-- Test function
if __name__ == "__main__":
    # Test state initialization
    # debug = True
    # debugpermutation = True

    message = b"ascon"

    print("=== [RE-] demo hash using Ascon-Hash ===")
    hashtag = ascon_hash(message, hashlength=32)

    print(f"Message: 0x{message.hex()} ({len(message)} bytes)")
    print(f"Hash tag: 0x{hashtag.hex()} ({len(hashtag)} bytes)")