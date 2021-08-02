reset
echo "=================================================================== "
echo "This script emulates an ephemeral Diffie-Hellam (EDH) key exchange "
echo "agreement between Alice and Bob. The exchange agreement is ephemeral "
echo "as the public key exchange paramters never get re-used."
echo "=================================================================== "

	sleep 5

echo "==DH== Generate DH initial parameters p (large prime) and g (the generator)"
	openssl dhparam -out dhp.pem 512 2>/dev/null
	openssl pkeyparam -in dhp.pem -text -noout

echo "==DH== Use the DH initial paramters to generate Bob's private key: g (generator), p (prime), b (private exponent), g^b*log(p) (public point) "
	openssl genpkey -paramfile dhp.pem -out dhkey_Bob.pem > /dev/null
  	openssl pkey -in dhkey_Bob.pem -text -noout

echo "==DH== Extract public information from Bob's private key (dhkey_Bob.pem) to produce
      public key: g (generator), p (prime), g^b*log(p) (Bob's public point)"
  	openssl pkey -in dhkey_Bob.pem -pubout -out  dhpub_Bob.pem
  	openssl  pkey -pubin -in dhpub_Bob.pem  -text -noout


echo "==DH== Use the DH initial paramters to generate Alices's 
      private key: g (generator), p (prime), a (private exponent), g^a*log(p) (public point) "
	openssl genpkey -paramfile dhp.pem -out dhkey_Alice.pem

echo "==DH== Extract public information from Alice's private key (dhkey_Alice.pem) to produce
      public key: g (generator), p (prime), g^a*log(p) (Alice's public point)"
 	openssl pkey -in dhkey_Alice.pem -pubout -out  dhpub_Alice.pem
	openssl  pkey -pubin -in dhpub_Alice.pem  -text -noout

echo "==DH== Alice derives common secret (secret_alice.bin) using their private key (dhkey_Alive) and Bob's peer key (dhpub_Bob)"
	openssl pkeyutl -derive -keyform PEM -inkey dhkey_Alice.pem -peerkey dhpub_Bob.pem -out secret_alice.bin

  
	echo "==DH== Bob independently derives common secret (secret_bob.bin) using their private key (dhkey_Bob) and Alices's peer key (dhpub_Alice)"
	openssl pkeyutl -derive -keyform PEM -inkey dhkey_Bob.pem -peerkey dhpub_Alice.pem -out secret_bob.bin

echo "=========================================================================================================="
echo "At this stage, secret_alice.bin and secret_bob.bin should be identical symmmetric keys:"
	sha256sum secret_*
	echo ""
echo "We can investigate how these derived keys can be used in a simplified encryption protocol:"
echo "1 - Alice encrypts the plain.txt file to produce cipher-sent.bin using secret_alice.bin."
echo "2 - for AES ecryption, Alice will also send a public 128 bit (16 byte) initialisation IV. "
echo "3 - Alice adds a simple message integrity check (could be replaced with more robust HMAC)."
echo "4 - Bob follows the protocol and first checks the integrity of the cipher text before decrypting."
echo "5 - if message integrity passes, Bob decrypts cipher-sent.bin into plain-received.txt using secret_bob.bin."
echo "=========================================================================================================="
	sleep 5
# We need to represent 16 random characters (16 bytes) into hex (0xXX):
echo "==ENC== Public information: we are generating a 128bit IV for the current encryption:"
	IV=$(hexdump -n 16 -e '"%X"'  /dev/urandom )
	echo $IV
echo ""
echo "==ENC== Alice encrypts \"plain.txt\", using the advertised IV, to produce \"cipher-sent.bin\" "
	openssl enc -e -iv $(echo $IV) -aes-256-cbc \
		-K $(hexdump -v -e '/1 "%02X"' secret_alice.bin) \
		-in plain.txt -out cipher-sent.bin 2>/dev/null
echo "==ENC== Public information: Alice sends basic integrity checks to Bob which they have agreed should be checked before proceeding with decryting received messages:"
	TAG=$((sha256sum cipher-sent.bin; echo ALICE) | sha256sum )
echo "==ENC== The chosen TAG (SHA256(SHA256 CIPHER | ALICE) is  $TAG"
# Now Bob will decrypt this message with their derived key, 
# but ONLY if the sent tag is the same as the one they calculate.
echo "==DEC== Bob evaluates message TAG"
	TAG2=$((sha256sum cipher-sent.bin; echo ALICIA) | sha256sum) 
echo "==DEC== Received TAG avaluated by Bob is: $TAG2"
	if [[ "$TAG2" == "$TAG" ]]; then 
		echo "==DEC== Message TAG test: PASSED ..."
		echo "==DEC== Bob decrypts \"cipher-sent.bin\", using the advetised IV, to produce \"plain-recieved.txt\" "
		openssl enc -d -iv $(echo $IV) -aes-256-cbc \
		-K $(hexdump -v -e '/1 "%02X"' secret_bob.bin) \
		-in cipher-sent.bin -out plain-received.bin 2>/dev/null
		cat plain-received.bin
	else
		echo "==ERROR== Message TAG test failed. Message integrity is not preserved. Will not decrypt."
		exit -1
	fi
echo "Done!"


