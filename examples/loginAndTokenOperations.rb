#!/usr/bin/ruby

require 'date'
require 'rest-client'
require 'json'
require 'openssl'
require 'eventmachine'
require 'faye/websocket'

apiPath = '../'

require "#{apiPath}/util/Random.rb"
require "#{apiPath}/util/RestClientWrapper.rb"
require "#{apiPath}/util/WebStompClient.rb"
require "#{apiPath}/util/ValueCheck.rb"
require "#{apiPath}/crypto/ECPublicKeyFormats.rb"
require "#{apiPath}/crypto/ECPrivateKeyFormats.rb"
require "#{apiPath}/crypto/ECCurves.rb"
require "#{apiPath}/crypto/ECKeyPair.rb"
require "#{apiPath}/crypto/ECDH.rb"
require "#{apiPath}/crypto/ECDSA.rb"
require "#{apiPath}/resource/AccessType.rb"
require "#{apiPath}/resource/AddressType.rb"
require "#{apiPath}/resource/Address.rb"
require "#{apiPath}/resource/CountryCode.rb"
require "#{apiPath}/resource/CountryName.rb"
require "#{apiPath}/resource/Email.rb"
require "#{apiPath}/resource/GenderType.rb"
require "#{apiPath}/resource/LoginTransaction.rb"
require "#{apiPath}/resource/NameTitles.rb"
require "#{apiPath}/resource/Name.rb"
require "#{apiPath}/resource/PhoneType.rb"
require "#{apiPath}/resource/Phone.rb"
require "#{apiPath}/resource/Person.rb"
require "#{apiPath}/resource/PropertyType.rb"
require "#{apiPath}/resource/TokenAccess.rb"
require "#{apiPath}/resource/TokenDurationType.rb"
require "#{apiPath}/resource/Token.rb"
require "#{apiPath}/resource/TokenStatus.rb"
require "#{apiPath}/resource/TokenWrapper.rb"
require "#{apiPath}/resource/User.rb"
require "#{apiPath}/resource/WebLoginAuthDetails.rb"
require "#{apiPath}/resource/WebLoginIdentifyingDetails.rb"
require "#{apiPath}/resource/WebLoginSessionDetails.rb"
require "#{apiPath}/actions/UserActions.rb"
require "#{apiPath}/actions/TokenActions.rb"
require "#{apiPath}/actions/PersonActions.rb"
require "#{apiPath}/config/Config.rb"

#############################################################################
#
# The following parameters need to be set to those of a current Citizen user.
#
primaryEmail = "test123@test.com";
password     = "Test1234"
passphrase   = "Test12" 
#
##############################################################################

userId     = ""
mnemonic   = ""
apiKey     = ""

# Log in with an email address and password, returning a User object.

user = UserActions.login(primaryEmail: primaryEmail,
                         password: password)

puts("*****************************************")
puts("UserActions.login()")
puts(user.toHash())
puts("*****************************************\n\n")

# The API key and user ID will be used in subsequent calls.

apiKey = user.apiKey
userId = user.id


# The user's mnemonic code is sent in calls to decrypt encrypted data.
# It can be obtained with the user's passphrase.

mnemonic = UserActions.getMnemonic(user: user,
                                   passPhrase: passphrase)

puts("*****************************************")
puts("UserActions.getMnemonic")
puts(mnemonic)
puts("*****************************************\n\n")


# It is also possible to log in using an EC P-256 (aka secp256r1 aka prime256v1) key. 

privateKeyPEM =
    "-----BEGIN EC PRIVATE KEY-----\n" +
    "MHcCAQEEIN167x9AR0nWS1pqe40N2Zg6Q1G/325h+ZesDUt8/wjhoAoGCCqGSM49\n" +
    "AwEHoUQDQgAEW25R41JJWtg7O242AP4VkyvFaHQIeRNFgAAlh/hzFDjqbAXXIcYB\n" +
    "qSOkised+qZqBUT02EQJ3CUpzm0glDmttQ==\n" +
    "-----END EC PRIVATE KEY-----\n"

publicKeyPEM =
    "-----BEGIN PUBLIC KEY-----\n" +
    "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEW25R41JJWtg7O242AP4VkyvFaHQI\n" +
    "eRNFgAAlh/hzFDjqbAXXIcYBqSOkised+qZqBUT02EQJ3CUpzm0glDmttQ==\n" +
    "-----END PUBLIC KEY-----\n"

ecdsa = ECDSA.new()
ecdsa.ecCurve=ECCurves::P256

ecdsa.importLocalPrivateKey(format: ECPrivateKeyFormats::PEM_STRING,
                            keyData: privateKeyPEM)

ecdsa.importLocalPublicKey(format: ECPublicKeyFormats::PEM_STRING,
                           keyData: publicKeyPEM)

# This is typically used for thumbprint logins, where the private key 
# is kept securely on a user's phone.
#
# A nonce generated by the Citizen Service is signed to log in. The
# public part of the key is sent to the Citizen Service so that 
# signatures can be verified. The user ID and API key identify are
# used to identify the user and ensure they have logged in.

user = UserActions.enrollDevicePublicKey(userId: userId,
                                         ecdsa: ecdsa,
                                         apiKey: apiKey)

puts("*****************************************")
puts("UserActions.enrollDevicePublicKey")
puts(user.toHash())
puts("*****************************************\n\n")

# The public key needs to be enrolled once. After it is enrolled then
# the user may use their private key to log in.

user = UserActions.loginWithSignedTransaction(primaryEmail: primaryEmail,
                                              ecdsa: ecdsa)

puts("*****************************************")
puts("UserActions.loginWithSignedTransaction")
puts(user)
puts("*****************************************\n\n")

# Once logged in, a token can be requested from another Citizen
# user. Let's say we want to request someone's name and data
# of birth.

# First the type of information to access is specified.

access = TokenAccess.new()
access.add(AccessType::NAME)
access.add(AccessType::DOB)

# Then the token is created.
#
# Any calls involving tokens require a user's mnemonic to be so
# that data can be decrypted - data about a user, including
# email addresses are stored encrypted on the Citizen Service.

token = TokenActions.createToken(requestorEmail: primaryEmail,
                                 userEmail: primaryEmail,
                                 access: access,
                                 durationType: TokenDurationType::MONTH,
                                 duration: 2,
                                 apiKey: apiKey,
                                 mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.createToken()")
puts(token.toHash())
puts("*****************************************\n\n")


# A user can get a list of all token requests that have been sent 
# to them.

tokenWrapper = TokenActions.getUserTokens(apiKey: apiKey,
                                          mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.getUserTokens()")
puts(tokenWrapper.toHash())
puts("*****************************************\n\n")

# And also a list of tokens token requests that they have sent
# to other Citizen users.

tokenWrapper = TokenActions.getRequesterTokens(apiKey: apiKey,
                                               mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.getRequesterTokens()")
puts(tokenWrapper.toHash())
puts("*****************************************\n\n")

# An individual token can be obtained using its token ID.

token = TokenActions.getToken(tokenId: token.id,
                              apiKey: apiKey,
                              mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.getToken()")
puts(token.toHash())
puts("*****************************************\n\n")

# If the user who's name and date of birth were requested decides 
# to allow the requesting user access to it, the 'grant' the token.
#
# The data comes back encrypted - it has been encrypted with the
# requesting user's public key.

token = TokenActions.grantToken(token: token,
                                apiKey: apiKey,
                                mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.grantToken()")
puts(token.toHash())
puts("*****************************************\n\n")

# The requesting user can get granted token using its token ID.

token = TokenActions.getToken(tokenId: token.id,
                              apiKey: apiKey,
                              mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.getToken()")
puts(token.toHash())
puts("*****************************************\n\n")

# Token fields may or may not be encrypted and new fields may
# also be added as part of continuing development. For these
# reasons, a hash rather than an object is used to address
# them. For the more common fields there are convenience
# methods to make manipulating data easier. For example,
# the DOB field in can be accessed as a Ruby Date object.

date = token.getDob()

puts("*****************************************")
puts("Date")
puts(date.to_s())
puts("*****************************************\n\n")

# It is also possible to request that a user 'sign' a token. 
# A typical use case is where they use their thumbprint to in
# the Citizen app to unlock their P-256 key and sign the token
# with it. This gives extra confidence that the user has 
# granted consent for access to their data.

access = TokenAccess.new()
access.add(AccessType::NAME)
access.add(AccessType::DOB)
access.add(AccessType::TOKEN_SIGNATURE)

token = TokenActions.createToken(requestorEmail: primaryEmail,
                                 userEmail: primaryEmail,
                                 access: access,
                                 durationType: TokenDurationType::MONTH,
                                 duration: 2,
                                 apiKey: apiKey,
                                 mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.createToken()")
puts(token.toHash())
puts("*****************************************\n\n")

# Upon receiving the token, the user may check if a signature 
# is requested.

token = TokenActions.getToken(tokenId: token.id,
                              apiKey: apiKey,
                              mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.getToken()")
puts(token.toHash())
puts("*****************************************\n\n")

signatureRequested = TokenAccess.contains(token.access, AccessType::TOKEN_SIGNATURE)

puts("*****************************************")
puts("AccessType::TOKEN_SIGNATURE")
puts(signatureRequested)
puts("*****************************************")

# On seeing that a signature is requested, the token is signed and
# granted.

token = TokenActions.signToken(token: token,
                               ecdsa: ecdsa)

puts("*****************************************")
puts("TokenActions.signToken()")
puts(token.toHash())
puts("*****************************************\n\n")

token = TokenActions.grantToken(token: token,
                                apiKey: apiKey,
                                mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.grantToken()")
puts(token.toHash())
puts("*****************************************\n\n")

# Upon receiving the granted token, the requesting user may
# verify the signature.

token = TokenActions.getToken(tokenId: token.id,
                              apiKey: apiKey,
                              mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.getToken()")
puts(token.toHash())
puts("*****************************************\n\n")

tokenSignatureVerified = TokenActions.verifySignedToken(token: token,
                                                        apiKey: apiKey)

puts("*****************************************")
puts("tokenSignatureVerified")
puts(tokenSignatureVerified)
puts("*****************************************\n\n")

# If a token is no longer needed it can be deleted.

deleted = TokenActions.deleteToken(tokenId: token.id,
                                   apiKey: apiKey,
                                   mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.deleteToken()")
puts(deleted)
puts("*****************************************\n\n")


# A token can also be 'declined'
#
# Let's say a Citizen user asks for another user's address.

access = TokenAccess.new()
access.add(AccessType::NAME)
access.add(AccessType::DOB)

token = TokenActions.createToken(requestorEmail: primaryEmail,
                                 userEmail: primaryEmail,
                                 access: access,
                                 durationType: TokenDurationType::MONTH,
                                 duration: 2,
                                 apiKey: apiKey,
                                 mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.createToken()")
puts(token.toHash())
puts("*****************************************\n\n")

# And the requested prefers not share their address.

token = TokenActions.declineToken(tokenId: token.id,
                                  apiKey: apiKey,
                                  mnemonic: mnemonic)

puts("*****************************************")
puts("TokenActions.declineToken()")
puts(token.toHash())
puts("*****************************************\n\n")


# All the token calls so far have passed the mnemonic as an argument
# because encrypted data is involved. The mnemonic is a sensitive
# piece of data that is usally stored securely somewhere like the 
# user's phone. If a user wants to access tokens from a relatively
# insecure environment, such as a web browser, a temporary key can
# be used in place of the mnemonic.
#
# To obtain a temporary key, a token is sent to the user's phone
# with a type of TokenStatus::WEB_ACCESS_REQUEST. Upon granting
# the token, a temporary key is sent through a web socket to the
# client requesting it. A nonce is used to identify the requesting 
# client.

puts("\nSending web access token request - grant this on phone!\n\n")

webLoginSessionDetails = UserActions.webLoginFromToken(email: primaryEmail)

puts("*****************************************")
puts("TokenActions.webLoginSessionDetails()")
puts(webLoginSessionDetails.toHash())
puts("*****************************************\n\n")

# The sessionNonce and sessionKey parameters can now be used in
# place of the mnemonic for token calls. The API key is also sent
# through the web socket.

tokenWrapper = TokenActions.getUserTokens(apiKey: webLoginSessionDetails.apiKey,
                                          sessionNonce: webLoginSessionDetails.sessionNonce,
                                          sessionKey: webLoginSessionDetails.sessionKey)

puts("*****************************************")
puts("TokenActions.getUserTokens()")
puts(tokenWrapper.toHash())
puts("*****************************************\n\n")
