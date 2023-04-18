function pause(){
	echo " "
	read -p "press enter key to proceed"
	echo " "
}

function lf(){
	echo "Files: "; ls 
}

if [[ $1 == 'clean' ]]
then
	echo "Cleaning files"
	rm cipher-sent.bin dhkey_Alice.pem dhkey_Bob.pem dhp.pem dhpub_Alice.pem dhpub_Bob.pem secret_alice.bin secret_bob.bin plain-received.txt
	exit 1
fi

reset
echo "=================================================================== "
echo "This script emulates an ephemeral Diffie-Hellman (EDH) key exchange "
echo "agreement between Alice and Bob. The exchange agreement is ephemeral "
echo "as the public key exchange parameters never get re-used."
echo "=================================================================== "

pause

echo "==DH== (1) Key Exchange"
echo " "
echo "==DH== 1.i"
echo "==DH== Generate DH initial parameters p (large prime) and g (the generator)"
echo "==DH== openssl dhparam -out dhp.pem 512"
openssl dhparam -out dhp.pem 512 2>/dev/null

echo "==DH== openssl pkeyparam -in dhp.pem -text -noout"
openssl pkeyparam -in dhp.pem -text -noout
lf

pause

echo "==DH== 1.ii"
echo "==DH== Use the DH initial parameters to generate Bob's private key: g (generator), p (prime), b (private exponent), g^b mod(p) (public point) "
echo "==DH== openssl genpkey -paramfile dhp.pem -out dhkey_Bob.pem"
openssl genpkey -paramfile dhp.pem -out dhkey_Bob.pem 2>/dev/null

echo "==DH== openssl pkey -in dhkey_Bob.pem -text -noout"
openssl pkey -in dhkey_Bob.pem -text -noout
lf

pause

echo "==DH== 1.iii"
echo "==DH== Extract public information from Bob's private key (dhkey_Bob.pem) to produce
      public key: g (generator), p (prime), g^b mod(p) (Bob's public point)"
echo "==DH== openssl pkey -in dhkey_Bob.pem -pubout -out  dhpub_Bob.pem"
openssl pkey -in dhkey_Bob.pem -pubout -out  dhpub_Bob.pem

echo "==DH== openssl pkey -pubin -in dhpub_Bob.pem  -text -noout"
openssl pkey -pubin -in dhpub_Bob.pem  -text -noout
lf

pause

echo "==DH== 1.iv"
echo "==DH== Use the DH initial paramters to generate Alices's 
      private key: g (generator), p (prime), a (private exponent), g^a mod(p) (public point) "
	
echo "==DH== openssl genpkey -paramfile dhp.pem -out dhkey_Alice.pem"
openssl genpkey -paramfile dhp.pem -out dhkey_Alice.pem
lf

pause

echo "==DH== 1.v"
echo "==DH== Extract public information from Alice's private key (dhkey_Alice.pem) to produce
      public key: g (generator), p (prime), g^a mod(p) (Alice's public point)"
echo "==DH== openssl pkey -in dhkey_Alice.pem -pubout -out  dhpub_Alice.pem"
openssl pkey -in dhkey_Alice.pem -pubout -out  dhpub_Alice.pem

echo "==DH== openssl  pkey -pubin -in dhpub_Alice.pem  -text -noout"
openssl  pkey -pubin -in dhpub_Alice.pem  -text -noout
lf

pause

echo "==DH== 1.vi"
echo "==DH== Alice derives common secret (secret_alice.bin) using their private key (dhkey_Alive) and Bob's peer key (dhpub_Bob)"
echo "==DH== openssl pkeyutl -derive -keyform PEM -inkey dhkey_Alice.pem -peerkey dhpub_Bob.pem -out secret_alice.bin"
openssl pkeyutl -derive -keyform PEM -inkey dhkey_Alice.pem -peerkey dhpub_Bob.pem -out secret_alice.bin
lf

pause
  
echo "==DH== 1.vii"
echo "==DH== Bob independently derives common secret (secret_bob.bin) using their private key (dhkey_Bob) and Alices's peer key (dhpub_Alice)"
echo "==DH== openssl pkeyutl -derive -keyform PEM -inkey dhkey_Bob.pem -peerkey dhpub_Alice.pem -out secret_bob.bin"
openssl pkeyutl -derive -keyform PEM -inkey dhkey_Bob.pem -peerkey dhpub_Alice.pem -out secret_bob.bin
lf 

pause

echo "==ENC== (2) Encryption"
echo " "
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

pause

echo "==ENC== We need to represent 16 random characters (16 bytes) into hex (0xXX)"
echo "==ENC== Public information: we are generating a 128bit IV for the current encryption:"
IV=$(hexdump -n 16 -e '"%X"'  /dev/urandom )
echo $IV

echo "==ENC== Alice encrypts \"plain.txt\", using the advertised IV, to produce \"cipher-sent.bin\" "
echo "==ENC== openssl enc -e -iv \$(echo \$IV) -aes-256-cbc \ "
echo "==ENC==		-K \$(hexdump -v -e '/1 "%02X"' secret_alice.bin) \ "
echo "==ENC==		-in plain.txt -out cipher-sent.bin"

openssl enc -e -iv $(echo $IV) -aes-256-cbc \
		-K $(hexdump -v -e '/1 "%02X"' secret_alice.bin) \
		-in plain.txt -out cipher-sent.bin 2>/dev/null

lf
pause

echo "==TAG== (3) Message Authentication Code"
echo " "
echo "==TAG== 3.i"
echo "==TAG== Public information: Alice sends basic integrity checks to Bob which they have agreed should be checked before proceeding with decrypting received messages:"
echo "==TAG== TAG=$((sha256sum cipher-sent.bin; echo ALICE) | sha256sum )"
TAG=$((sha256sum cipher-sent.bin; echo ALICE) | sha256sum )

echo "==TAG== The chosen TAG (SHA256(SHA256 CIPHER | ALICE) is  $TAG"

pause 

echo "==TAG== 3.ii"
echo "==TAG== Now Bob will decrypt this message with their derived key, "
echo "==TAG== but ONLY if the sent tag is the same as the one they calculate."
echo "==TAG== Bob evaluates message TAG"
echo "==TAG== TAG2=$((sha256sum cipher-sent.bin; echo ALICIA) | sha256sum) "
TAG2=$((sha256sum cipher-sent.bin; echo ALICIA) | sha256sum) 


echo "==TAG== Received TAG evaluated by Bob is: $TAG2"

pause

echo "==TAG== Testing tags:"
if [[ "$TAG2" == "$TAG" ]]; then 
	echo "==DEC== (4) Decryption"
	echo " "
	echo "==DEC== Message TAG test: PASSED ..."
	echo "==DEC== Bob decrypts \"cipher-sent.bin\", using the advertised IV, to produce \"plain-received.txt\" "
	openssl enc -d -iv $(echo $IV) -aes-256-cbc \
	-K $(hexdump -v -e '/1 "%02X"' secret_bob.bin) \
	-in cipher-sent.bin -out plain-received.txt 2>/dev/null
	cat plain-received.txt
else
	echo "==ERROR== Message TAG test failed. Message integrity is not preserved. Will not decrypt."
	exit -1
fi
echo "Done!"


