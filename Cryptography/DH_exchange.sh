echo "==== Generate DH initial parameters p (large prime) and g (the generator)"
 	openssl dhparam -out dhp.pem 512
	openssl pkeyparam -in dhp.pem -text -noout

echo "==== Use the DH initial paramters generate Bob's private key: g (generator), p (prime), b (private exponent), g^b*log(p) (public point) "
	openssl genpkey -paramfile dhp.pem -out dhkey_Bob.pem
  	openssl pkey -in dhkey_Bob.pem -text -noout

echo "==== Extract public information from private key dhkey_Bob.pem to produce
      public key: g (generator), p (prime), g^b*log(p) (Bob's public point)"
  	openssl pkey -in dhkey_Bob.pem -pubout -out  dhpub_Bob.pem
  	openssl  pkey -pubin -in dhpub_Bob.pem  -text -noout


echo "==== Use the DH initial paramters to generate Alices's 
      private key: g (generator), p (prime), a (private exponent), g^a*log(p) (public point) "
	openssl genpkey -paramfile dhp.pem -out dhkey_Alice.pem

echo "==== Extract public information from private key dhkey_Alice.pem to produce
      public key: g (generator), p (prime), g^a*log(p) (Alice's public point)"
 	openssl pkey -in dhkey_Alice.pem -pubout -out  dhpub_Alice.pem
	openssl  pkey -pubin -in dhpub_Alice.pem  -text -noout

echo "==== Alice derives common secret using her private key (dhkey_Alive) and Bob's peer key (dhpub_Bob)"
	openssl pkeyutl -derive -keyform PEM -inkey dhkey_Alice.pem -peerkey dhpub_Bob.pem -out secret_alice.bin

  
echo "==== Bob derives common secret using his private key (dhkey_Bob) and Alices's peer key (dhpub_Alice)"
	openssl pkeyutl -derive -keyform PEM -inkey dhkey_Bob.pem -peerkey dhpub_Alice.pem -out secret_bob.bin
