// about
/*

//WeekEnd Project
PROJECT: TWITTER #XMAS TREE
Version 1.0.0 - 2012.12.14

//Files:
- processing: twitterbridge3.pde (twitter connection and light control)
- arduino: TwitterXMasTree.ino (hardware / software bridge)
- schema: CircuitoLuci_01.pdf (circuit)

//By Daniele Iori (hold3n)
** www.ibridodesign.com
** daniele.temp@gmail.com

//Concept IT
E' un semplice script che si connette a twitter, cerca i messaggi con la parola #xmas 
e poi invia la sequenza temporale ad arduinoo. Arduino a sua volta controlla 
la frequenza di accensione e spegnimento delle luci. 
La frequenza corrisponde ai secondi che intercorrono tra un tweet e l'altro.

Più ci si avvicina al natale, più la frequenza cresce, più uno vede fisicamente la frenesia del natale, 
fino al punto che poi l'albero svampa. Proprio come le persone sotto natale.

//Concept EN
It 'a simple script connected to twitter. 
It works searching for messages with the hashtag #xmas and sending the timeline to arduino. 
So Arduino controls the frequency turning on and off the lights. 
The frequency corresponds to the seconds between a tweet and the following one.

During the days before Christmas, the frequency grows up and grows up! Until the Christmas Day! 
You can see the physical frenzy of Christmas speed up until the lights burn out!
Just like people in the home.




//This project uses:
** Twitter4J library - http://twitter4j.org/

This project uses or is based on parts of:
** Simple Processing Twitter - http://robotgrrl.com/blog/2011/02/21/simple-processing-twitter/
** simpleTweet_00 processing - http://www.instructables.com/id/Simple-Tweet-Arduino-Processing-Twitter/
** Tweeting Christmas Tree - http://www.instructables.com/id/Tweeting-Christmas-Tree/
** Twitter Mention Mood Light - http://www.instructables.com/id/Twitter-Mention-Mood-Light/
** Twitter Mood Light - http://www.instructables.com/id/Twitter-Mood-Light-The-Worlds-Mood-in-a-Box


This work is licensed under a Creative Commons Attribution 3.0 - http://creativecommons.org/licenses/by/3.0/

*/

char val; // Data received from the serial port
int ledPin = 9; // Set the pin to digital I/O 4

void setup() {
  pinMode(ledPin, OUTPUT); // Set pin as OUTPUT
  Serial.begin(9600); // Start serial communication at 9600 bps
}

void loop() {
  if (Serial.available()) { // If data is available to read,
    val = Serial.read(); // read it and store it in val
    //Serial.print(val);
  }
  if (val == '1') { // If H was received
    for (int i=0; i <= 256; i++){ //conto da 0 a 255
      analogWrite(ledPin,i);
      delay(4);
    }  
    for (int i=255; (i > -1); i--){ //e da 255 a 1
      analogWrite(ledPin,i);
      delay(2);
    } 
  } 
  //delay(100)
  // Wait 100 milliseconds for next reading
}


