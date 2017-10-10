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
# The following parameters need to be set to those of a valid phone number.
#
phoneNumber      = "12345678"
phoneCountryCode = "GB"
#
#############################################################################

primaryEmail = Random.getRandomString(16) + "@test.com";
password     = "Test1234"
passphrase   = "Test12" 
apiKey       = ""
mnemonic     = ""
personId     = ""

# A new user can be created by specifying an email address, password and passphrase.

user = UserActions.createUser(primaryEmail: primaryEmail,
                              password: password,
                              passPhrase: passphrase)

puts("*****************************************")
puts("UserActions.createUser()")
puts(user.toHash())
puts("*****************************************\n\n")

apiKey = user.apiKey
mnemonic = user.mnemonicCode
personId = user.personId

# The User object returned primarily concerns login and key functionality. 
# A Person object can also be obtained with info about the user.

person = PersonActions.getPerson(personId: personId,
                                 apiKey: apiKey,
                                 mnemonic: mnemonic)

puts("*****************************************")
puts("PersonActions.getPerson()")
puts(person.toHash())
puts("*****************************************\n\n")

# The person object returned has no details about the user. Their name can be added
# as follows. The user's mnemonic is not required here because data is not being 
# decrypted it is being encrypted on the Citizen Service with the user's public key.

name = Name.new()
name.title=NameTitles::MR
name.firstName="John"
name.middleName="Paul"
name.lastName="Doe"
name.gender=GenderType::MALE

person = PersonActions.setName(personId: personId,
                               name: name,
                               apiKey: apiKey)

puts("*****************************************")
puts("PersonActions.setName()")
puts(person.toHash())
puts("*****************************************\n\n")

# The user's addres is set as follows. Note that the country must be a two letter
# ISO-3166 country code.
                               
address = Address.new()
address.addressLine1="101 Main Street"
address.addressLine2="Main Avenue"
address.addressLine3="Main Town"
address.city="Mainton"
address.state="Maine"
address.countryName="GB"
address.addressType=AddressType::HOME
address.postCode="111 222"

address = PersonActions.setAddress(personId: personId,
                                   address: address,
                                   apiKey: apiKey)

puts("*****************************************")
puts("PersonActions.setAddress()")
puts(address.toHash())
puts("*****************************************\n\n")


# The user's phone can be added as follows.

phone = Phone.new()
phone.personId=personId
phone.countryCode=phoneCountryCode
phone.phoneNumber=phoneNumber
phone.phoneType=PhoneType::MOBILE

phone = PersonActions.setPhone(phone: phone,
                               apiKey: apiKey)

puts("*****************************************")
puts("PersonActions.setPhone()")
puts(phone.toHash())
puts("*****************************************\n\n")

# Upon restering the user's phone, an SMS message is sent with a confirm
# code. This confirm code may be sent to the Citizen Service as follows.

puts("Enter SMS confirm code!\n\n")

confirmCode = gets()

confirmCode = confirmCode.gsub(/[^0-9]/, '')

phone.smsConfirmCode=confirmCode

phoneVerificationSent = PersonActions.confirmPhone(phone: phone,
                                                   apiKey: apiKey)

puts("*****************************************")
puts("PersonActions.confirmPhone()")
puts(phoneVerificationSent)
puts("*****************************************\n\n")

# The verification status can be obtained from a Phone object.

phone = PersonActions.getPhone(personId: personId,
                               apiKey: apiKey,
                               mnemonic: mnemonic)

puts("*****************************************")
puts("PersonActions.getPhone()")
puts(phone.toHash())
puts("*****************************************\n\n")

# The user's date of birth, place of birth and nationality are set as follows.
# These currently need to be set together, but they will be able to be set
# individually in a future release.
#
# Note here that the data in the person object is returned encrypted because
# it has ready been initialised in an earlier call.

person.dateOfBirth=Date.new(1984, 4, 27)
person.countryNationality="GB"
person.placeOfBirth="London"

person = PersonActions.setOrigin(person: person,
                                 apiKey: apiKey)

puts("*****************************************")
puts("PersonActions.setOrigin()")
puts(person.toHash())
puts("*****************************************\n\n")

# Finally, a decrypted Person object with the new data can be obtained
# as follows.

person = PersonActions.getPerson(personId: personId,
                                 apiKey: apiKey,
                                 mnemonic: mnemonic)

puts("*****************************************")
puts("PersonActions.getPerson()")
puts(person.toHash())
puts("*****************************************\n\n")
